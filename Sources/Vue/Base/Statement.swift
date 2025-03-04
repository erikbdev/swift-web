public protocol StatementRepresentable {
  var statement: String { get }
}

public struct Statement: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, StatementRepresentable {
  public var statement: String { rawValue }

  public init(
    keyword: Keyword? = nil,
    name: String,
    value: Expression
  ) {
    self.rawValue = "\(keyword.flatMap { "\($0.rawValue) " } ?? "")\(name) = \(value.expression);"
  }

  public enum Keyword: String {
    case `var`
    case `let`
    case const
  }

  public let rawValue: String

  public init(stringLiteral value: StringLiteralType) {
    self.rawValue = value
  }

  static func == (lhs: String, rhs: Statement) -> Bool {
    lhs == rhs.rawValue
  }

  public func render() -> String { rawValue }
}
