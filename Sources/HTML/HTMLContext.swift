import Dependencies

struct HTMLContext: Sendable {
  let config: HTMLFormatterConfig
  var depth: UInt = 0

  var currentIndentation: String { String(repeating: config.indentation, count: Int(depth)) }
}

extension HTMLContext: TestDependencyKey {
  static var liveValue: HTMLContext { .init(config: .minified) }
  static var testValue: HTMLContext { .init(config: .pretty) }
  static var previewValue: HTMLContext { .init(config: .pretty) }
}

extension DependencyValues {
  var htmlContext: HTMLContext {
    get { self[HTMLContext.self] }
    set { self[HTMLContext.self] = newValue }
  }
}

public struct HTMLFormatterConfig: Sendable {
  let indentation: String
  let newLine: String

  public static let minified = Self(indentation: "", newLine: "")
  public static let pretty = Self(indentation: "  ", newLine: "\n")
}

extension DependencyValues {
  public var htmlFormatterConfig: HTMLFormatterConfig {
    get { self[HTMLContext.self].config }
    set { self[HTMLContext.self] = HTMLContext(config: newValue, depth: self[HTMLContext.self].depth) }
  }
}
