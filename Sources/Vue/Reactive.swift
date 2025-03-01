/// `reactive`
@dynamicMemberLookup
public struct Reactive: ExpressionRepresentable {
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

  var statement: Statement { 
    Statement(keyword: .const, name: name, value: Expression(rawValue: "ref(\(value.expression))")) 
  }

  public func assign(_ expression: Expression) -> Statement {
    "\(name) = \(expression.expression);"
  }

  public func assign<E: ExpressionRepresentable>(_ expression: E) -> Statement {
    "\(name) = \(expression.expression);"
  }
}

public extension HTMLBuilder {
  static func buildExpression(_ reactive: Reactive) -> HTMLRaw {
    HTMLRaw("{{ \(reactive.name) }}")
  }
}