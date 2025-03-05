import Dependencies

struct HTMLContext: Sendable {
  let config: HTMLOutputConfig
  var depth: UInt = 0

  var currentIndentation: String { String(repeating: config.indentation, count: Int(depth)) }
}

extension HTMLContext: TestDependencyKey {
  static var testValue: HTMLContext { .init(config: .pretty) }
}

extension DependencyValues {
  // var htmlContext: HTMLContext {
  //   get { self[HTMLContext.self] }
  //   set { self[HTMLContext.self] = newValue }
  // }
}
