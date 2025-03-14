import Foundation
import HTML

public struct AnyEncodable: Encodable {
  let base: any Encodable

  public func encode(to encoder: any Encoder) throws {
    try base.encode(to: encoder)
  }
}

public struct RawExpression: Sendable {}

@dynamicMemberLookup
public struct Expression<Value> {
  private let base: Value
  public let rawValue: String

  /// Build a JS object
  public init<each T: Encodable>(_ properties: repeat (String, each T)) where Value == [String: AnyEncodable] {
    var object: [String: AnyEncodable] = [:]

    for (key, value) in repeat each properties {
      object[key] = AnyEncodable(base: value)
    }

    self.base = object
    self.rawValue =
      if let data = try? JSONEncoder.json.encode(object) {
        String(decoding: data, as: UTF8.self)
      } else {
        "null"
      }
  }

  /// Accept a encoded value
  public init(_ value: Value) where Value: Encodable {
    self.base = value
    self.rawValue =
      if let data = try? JSONEncoder.json.encode(value) {
        String(decoding: data, as: UTF8.self)
      } else {
        "null"
      }
  }

  public init(rawValue: String) where Value == RawExpression {
    self.base = RawExpression()
    self.rawValue = rawValue
  }

  @inlinable @inline(__always)
  public subscript(dynamicMember name: String) -> Expression<RawExpression> {
    .init(rawValue: "\(self.rawValue).\(name)")
  }
}

extension Expression where Value: Encodable {
  public var initialValue: Value { self.base }
}

extension Expression: ExpressibleByBooleanLiteral where Value == Bool {
  @inlinable @inline(__always)
  public init(booleanLiteral value: Bool) {
    self.init(value)
  }
}

extension Expression: ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByUnicodeScalarLiteral, ExpressibleByStringLiteral
where Value == String {
  @inlinable @inline(__always)
  public init(stringLiteral value: String) {
    self.init(value)
  }
}

extension Expression: ExpressibleByNilLiteral where Value == String? {
  @inlinable @inline(__always)
  public init(nilLiteral: ()) {
    self.init(.none)
  }
}

extension Expression: ExpressibleByIntegerLiteral where Value == Int {
  @inlinable @inline(__always)
  public init(integerLiteral value: IntegerLiteralType) {
    self.init(value)
  }
}

extension Expression: ExpressibleByFloatLiteral where Value == Double {
  @inlinable @inline(__always)
  public init(floatLiteral value: FloatLiteralType) {
    self.init(value)
  }
}

extension Expression: ExpressibleByArrayLiteral where Value == [AnyEncodable] {
  public init(arrayLiteral elements: (any Encodable)...) {
    self.init(elements.map(AnyEncodable.init(base:)))
  }
}

extension Expression: CustomStringConvertible {
  @inlinable @inline(__always)
  public var description: String { rawValue }
}

// extension Expression: ExpressibleByDictionaryLiteral {
//   public init(dictionaryLiteral elements: (String, String)...) {
//     self.init(Dictionary(elements, uniquingKeysWith: { $1 }))
//   }
// }

extension Expression {
  public func callAsFunction<each T: Encodable>(_ args: repeat each T) -> Expression<RawExpression> {
    var values: [String] = []
    for value in repeat each args {
      let encoded =
        if let data = try? JSONEncoder.json.encode(value) {
          String(decoding: data, as: UTF8.self)
        } else {
          "null"
        }
      values.append(encoded)
    }
    return .init(rawValue: self.rawValue + "(\(values.joined(separator: ", ")))")
  }

  public func callAsFunction<each T>(_ args: repeat Expression<each T>) -> Expression<RawExpression> {
    var values: [String] = []
    for expr in repeat each args {
      values.append(expr.rawValue)
    }
    return .init(rawValue: self.rawValue + "(\(values.joined(separator: ", ")))")
  }

  @inlinable @inline(__always)
  public func assign<T>(_ expression: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(self.rawValue) = \(expression)")
  }

  @inlinable @inline(__always)
  public static func * <T>(lhs: Self, rhs: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(lhs.rawValue) * \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func *= <T>(lhs: Self, rhs: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(lhs.rawValue) *= \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func / <T>(lhs: Self, rhs: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(lhs.rawValue) / \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func /= <T>(lhs: Self, rhs: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(lhs.rawValue) /= \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func + <T>(lhs: Self, rhs: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(lhs.rawValue) + \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func += <T>(lhs: Self, rhs: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(lhs.rawValue) += \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func - <T>(lhs: Self, rhs: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(lhs.rawValue) - \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func -= <T>(lhs: Self, rhs: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(lhs.rawValue) -= \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func == <T>(lhs: Self, rhs: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(lhs.rawValue) == \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func != <T>(lhs: Self, rhs: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(lhs.rawValue) != \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func === <T>(lhs: Self, rhs: Expression<T>) -> Expression<RawExpression> {
    .init(rawValue: "\(lhs.rawValue) === \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static prefix func ! (lhs: Self) -> Expression<RawExpression> {
    .init(rawValue: "!\(lhs.rawValue)")
  }
}

extension Expression: Sendable where Value: Sendable {}

extension JSONEncoder {
  fileprivate static let json = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .useDefaultKeys
    encoder.dataEncodingStrategy = .deferredToData
    encoder.dateEncodingStrategy = .iso8601
    encoder.nonConformingFloatEncodingStrategy = .convertToString(
      positiveInfinity: "0",
      negativeInfinity: "0",
      nan: "0"
    )
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    return encoder
  }()
}

extension HTMLBuilder {
  // Prioritize ``HTMLBuilder.buildExpression(_:HTMLString)``
  @_disfavoredOverload
  @inlinable @inline(__always)
  public static func buildExpression<T>(_ expression: Expression<T>) -> HTMLString {
    HTMLRaw("{{ \(expression.rawValue) }}")
  }
}

extension HTMLString.StringInterpolation {
  @inlinable @inline(__always)
  public mutating func appendInterpolation<T>(_ expression: Expression<T>) {
    appendInterpolation(raw: "{{ \(expression.rawValue) }}")
  }
}
