import Dependencies

public protocol HTMLByteStream {
  mutating func write(_ bytes: consuming UnsafeBufferPointer<UInt8>)
}

extension HTMLByteStream {
  public mutating func write(_ byte: UInt8) {
    [byte].withUnsafeBufferPointer { self.write($0)  }
  }
}

extension String: HTMLByteStream {
  @inlinable @inline(__always)
  public mutating func write(_ bytes: consuming UnsafeBufferPointer<UInt8>) {
    self.append(String(decoding: bytes, as: UTF8.self))
  }
}

extension HTML {
  @inline(__always)
  public consuming func render() -> String {
    var result = ""
    // withDependencies {
    //   $0.htmlContext = HTMLContext(config: $0.htmlConfig)
    // } operation: { [self] in
    Self._render(self, into: &result)
    // }
    return result
  }

  @inline(__always)
  public consuming func render<Output: HTMLByteStream>(into output: inout Output) {
    // withDependencies {
    //   $0.htmlContext = HTMLContext(config: $0.htmlConfig)
    // } operation: { [self] in
    Self._render(self, into: &output)
    // }
  }
}

public struct HTMLOutputConfig: Sendable {
  let indentation: String
  let newLine: String

  public static let minified = Self(indentation: "", newLine: "")
  public static let pretty = Self(indentation: "  ", newLine: "\n")
}

extension HTMLOutputConfig: DependencyKey {
  public static let liveValue = Self.minified
  public static let testValue = Self.pretty
  public static let previewValue = Self.pretty
}

extension DependencyValues {
  public var htmlConfig: HTMLOutputConfig {
    get { self[HTMLOutputConfig.self] }
    set { self[HTMLOutputConfig.self] = newValue }
  }
}
