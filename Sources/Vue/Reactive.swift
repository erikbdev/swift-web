import Dependencies

/// `reactive`
@dynamicMemberLookup
public struct Reactive: Sendable, Hashable, ExpressionRepresentable {
  public let name: String
  public let value: Expression

  public init(
    name: String,
    value: Expression
  ) {
    self.name = name
    self.value = value
  }

  @_disfavoredOverload
  public init<T: Encodable>(
    name: String,
    value: T?
  ) {
    self.name = name
    switch value {
    case .none: self.value = nil
    case .some: self.value = nil
    }
  }

  public var expression: String { name }

  var initializer: String {
    "const \(name) = ref(\(value.expression));"
  }
}

extension HTMLBuilder {
  public static func buildExpression(_ reactive: Reactive) -> HTMLString {
    HTMLRaw("{{ \(reactive.name) }}")
  }
}

extension HTMLString.StringInterpolation {
  public mutating func appendInterpolation(_ reactive: Reactive) {
    appendInterpolation(raw: "{{ \(reactive.name) }}")
  }
}
