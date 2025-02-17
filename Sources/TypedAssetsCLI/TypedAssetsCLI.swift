import ArgumentParser
import Foundation

@main
struct TypedAssetsCLI: ParsableCommand {
  @Option(name: [.customLong("input")], help: "Directory containing all files it should generate static")
  var inputs: [String]

  @Option(help: "The path where the generated output will be created")
  var output: String

  func run() throws {
    let outFile = URL(filePath: output, directoryHint: .notDirectory)

    let fileName = outFile.deletingPathExtension().lastPathComponent
    let fileExt = outFile.pathExtension

    guard fileExt == "swift" else {
      throw Error.swiftExtensionNotInOutfile
    }

    let items = inputs.map { Self.recursive(URL(filePath: $0, directoryHint: .checkFileSystem)) }

    try """
    import Foundation
    public struct \(fileName.pascalCase()): Swift.Sendable {
      public let baseURL: URL
      public init() {
        self.baseURL = Bundle.module.bundleURL
      }
      public init(_ baseURL: URL) {
        self.baseURL = baseURL
      }
      \(items.map { $0.code(isFirstLevel: true) }.joined(separator: "\n"), indent: 2)
      public protocol File {
        var name: String { get }
        var ext: String? { get }
        var url: URL { get }
      }
      public struct AnyFile: Swift.Sendable {
        public let name: String
        public let ext: String?
        public let url: URL
      }
      public struct ImageFile: Swift.Sendable {
        public let name: String
        public let ext: String?
        public let url: URL
        public let width: Int?
        public let height: Int?
      }
      public struct VideoFile: Swift.Sendable {
        public let name: String
        public let ext: String?
        public let url: URL
        public let width: Int?
        public let height: Int?
        public let mime: String
      }
    }
    """
    .write(to: outFile, atomically: true, encoding: .utf8)

    print("Successfully parsed '\(inputs)' directory and generated to '\(output)'")
  }

  private enum Error: Swift.Error {
    case swiftExtensionNotInOutfile
  }

  private static func recursive(_ url: URL) -> FileOrDir {
    var isDirectory = false
    _ = FileManager.default.fileExists(atPath: url.path(), isDirectory: &isDirectory)

    if isDirectory {
      guard let enumerator = try? FileManager.default.contentsOfDirectory(
        at: url, 
        includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey], 
        options: [.skipsHiddenFiles]
      ) else {
        return .dir(canonical: url.lastPathComponent, [])
      }

      return .dir(
        canonical: url.lastPathComponent, 
        enumerator.compactMap(Self.recursive)
      )
    } else {
      return .file(
        canonical: url.deletingPathExtension().lastPathComponent, 
        ext: url.pathExtension.isEmpty ? nil : url.pathExtension,
        type: .from(ext: url.pathExtension)
      )
    }
  }

  private enum FileOrDir {
    case dir(canonical: String, [Self])
    case file(canonical: String, ext: String?, type: FileType)

    func code(path: [String] = [], isFirstLevel: Bool = false) -> String {
      switch self {
        case let .dir(canonical, items):
          """
          public var `\(canonical.camelCase())`: \(canonical.pascalCase()) {
            \(canonical.pascalCase())(baseURL: \(isFirstLevel ? "URL(filePath: \"\(canonical)\", directoryHint: .isDirectory, relativeTo: self.baseURL)" : "self.baseURL.appending(path: \"\(canonical)\", directoryHint: .isDirectory)"))
          }
          public struct \(canonical.pascalCase()): Swift.Sendable {
            public let baseURL: URL
            \(items.map { $0.code(path: path + [canonical]) }.joined(separator: "\n"), indent: 2)
          }
          """
        case let .file(canonical, ext, type):
        switch type {
          case .unknown:
          """
          public var `\(canonical.camelCase() + (ext?.pascalCase() ?? ""))`: AnyFile {
            .init(
              name: "\(canonical)", 
              ext: \(ext.flatMap { "\"\($0)\"" } ?? "nil"),
              url: self.baseURL.appending(path: "\(canonical)", directoryHint: .notDirectory)\(ext.flatMap { ".appendingPathExtension(\"\($0)\")" } ?? "")
            )
          }
          """
          case .image(let width, let height):
          """
          public var `\(canonical.camelCase() + (ext?.pascalCase() ?? ""))`: ImageFile {
            .init(
              name: "\(canonical)", 
              ext: \(ext.flatMap { "\"\($0)\"" } ?? "nil"),
              url: self.baseURL.appending(path: "\(canonical)", directoryHint: .notDirectory)\(ext.flatMap { ".appendingPathExtension(\"\($0)\")" } ?? ""),
              width: \(width.flatMap(String.init) ?? "nil"),
              height: \(height.flatMap(String.init) ?? "nil")
            )
          }
          """
          case let .video(width, height, mime):
          """
          public var `\(canonical.camelCase() + (ext?.pascalCase() ?? ""))`: VideoFile {
            .init(
              name: "\(canonical)", 
              ext: \(ext.flatMap { "\"\($0)\"" } ?? "nil"),
              url: self.baseURL.appending(path: "\(canonical)", directoryHint: .notDirectory)\(ext.flatMap { ".appendingPathExtension(\"\($0)\")" } ?? ""),
              width: \(width.flatMap(String.init) ?? "nil"),
              height: \(height.flatMap(String.init) ?? "nil"),
              mime: "\(mime)"
            )
          }
          """
        }
      }
    }

    enum FileType {
      case image(width: Int?, height: Int?)
      case video(width: Int?, height: Int?, mime: String)
      case unknown

      static func from(ext: String) -> Self {
        switch ext.trimmingCharacters(in: .whitespacesAndNewlines) {
          case "gif": .image(width: nil, height: nil)
          case "jpeg", "jpg": .image(width: nil, height: nil)
          case "svg": .image(width: nil, height: nil)
          case "webp": .image(width: nil, height: nil)
          case "png": .image(width: nil, height: nil)
          case "mp4": .video(width: nil, height: nil, mime: "video/mp4")
          case "mov": .video(width: nil, height: nil, mime: "video/quicktime")
          case "webm": .video(width: nil, height: nil, mime: "video/webm")
          default: .unknown
        }
      }
    }
  }
}

private extension String {
  func pascalCase() -> Self {
    self.split { !$0.isLetter && !$0.isNumber }
    .map {
      if let first = $0.first?.uppercased() {
        return first[...] + $0.dropFirst()
      } else {
        return $0
      }
    }
    .joined()
  }

  func camelCase() -> Self {
    var initialLowercased = false
    return self.split { !$0.isLetter && !$0.isNumber }
      .map {
        if !initialLowercased {
          defer { initialLowercased = true }
          if let first = $0.first?.lowercased() {
            return first[...] + $0.dropFirst()
          } else {
            return $0.lowercased()[...]
          }
        } else if let first = $0.first?.uppercased() {
          return first[...] + $0.dropFirst()
        } else {
          return $0
        }
      }
      .joined()
  }
}

private extension String.StringInterpolation {
  mutating func appendInterpolation<S: StringProtocol>(_ value: S, indent: Int) {
    appendInterpolation(value.components(separatedBy: "\n").joined(separator: "\n\(String(repeating: " ", count: indent))"))
  }
}