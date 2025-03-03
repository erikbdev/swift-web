import Dependencies

struct HTMLContext: Sendable {
  let config: HTMLOutputConfig
  let currentIndentation = ""
  var depth: UInt = 0
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
