public protocol ExpressionRepresentable {
  var expression: String { get }
}

extension ExpressionRepresentable {
  public static func * <E1: ExpressionRepresentable>(lhs: Self, rhs: E1) -> Expression {
    Expression(rawValue: "\(lhs.expression) * \(rhs.expression)")
  }

  public static func / <E1: ExpressionRepresentable>(lhs: Self, rhs: E1) -> Expression {
    Expression(rawValue: "\(lhs.expression) / \(rhs.expression)")
  }

  public static func + <E1: ExpressionRepresentable>(lhs: Self, rhs: E1) -> Expression {
    Expression(rawValue: "\(lhs.expression) + \(rhs.expression)")
  }

  public static func - <E1: ExpressionRepresentable>(lhs: Self, rhs: E1) -> Expression {
    Expression(rawValue: "\(lhs.expression) - \(rhs.expression)")
  }

  public static func * <E1: Encodable>(lhs: Self, rhs: E1) -> Expression {
    Expression(rawValue: "\(lhs.expression) * \(rhs)")
  }

  public static func / <E1: Encodable>(lhs: Self, rhs: E1) -> Expression {
    Expression(rawValue: "\(lhs.expression) / \(rhs)")
  }

  public static func + <E1: Encodable>(lhs: Self, rhs: E1) -> Expression {
    Expression(rawValue: "\(lhs.expression) + \(rhs)")
  }

  public static func - <E1: Encodable>(lhs: Self, rhs: E1) -> Expression {
    Expression(rawValue: "\(lhs.expression) - \(rhs)")
  }

  public static prefix func ! (lhs: Self) -> Expression {
    Expression(rawValue: "!\(lhs.expression)")
  }

  public subscript(dynamicMember function: String) -> (Expression...) -> Expression {
    { args in
      Expression(rawValue: "\(self.expression).\(function)(\(args.map(\.expression).joined(separator: ", ")))")
    }
  }

  public subscript(dynamicMember property: String) -> Expression {
    Expression(rawValue: "\(self.expression).\(property)")
  }
}

@dynamicMemberLookup
public struct Expression: CustomStringConvertible, ExpressionRepresentable {
  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public var expression: String { rawValue }
  public var description: String { rawValue }

  static func * (lhs: Self, rhs: Self) -> Expression {
    Expression(rawValue: "\(lhs.expression) * \(rhs.expression)")
  }

  static func / (lhs: Self, rhs: Self) -> Expression {
    Expression(rawValue: "\(lhs.expression) * \(rhs.expression)")
  }

  static func + (lhs: Self, rhs: Self) -> Expression {
    Expression(rawValue: "\(lhs.expression) * \(rhs.expression)")
  }

  static func - (lhs: Self, rhs: Self) -> Expression {
    Expression(rawValue: "\(lhs.expression) * \(rhs.expression)")
  }

  static prefix func ! (lhs: Self) -> Expression {
    Expression(rawValue: "!\(lhs.expression)")
  }
}

extension Expression: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
  public init(stringLiteral value: StringLiteralType) {
    rawValue = "\"\(value)\""
  }
}

extension Expression: ExpressibleByNilLiteral {
  public init(nilLiteral _: ()) {
    rawValue = "null"
  }
}

extension Expression: ExpressibleByArrayLiteral {
  public init(arrayLiteral _: Encodable...) {
    rawValue = "[]"
  }
}

extension Expression: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: BooleanLiteralType) {
    rawValue = String(value)
  }
}

extension Expression: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral _: (AnyHashable, AnyHashable)...) {
    rawValue = "{}"
  }
}

extension Expression: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    rawValue = String(value)
  }
}

extension Expression: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    rawValue = String(value)
  }
}

extension String.StringInterpolation {
  public mutating func appendInterpolation<E: ExpressionRepresentable>(_ expression: E) {
    appendInterpolation("{{ \(expression.expression) }}")
  }

  public mutating func appendInterpolation(_ expression: Expression) {
    appendInterpolation("{{ \(expression.expression) }}")
  }
}
