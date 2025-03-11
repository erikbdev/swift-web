import Foundation
import HTML

private struct AnyEncodable: Encodable {
  let base: any Encodable

  func encode(to encoder: any Encoder) throws {
    try base.encode(to: encoder)
  }
}

@dynamicMemberLookup
public struct Expression: Sendable, RawRepresentable {
  /// The expression in JS
  public let rawValue: String

  private static let jsonEncoder = {
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

  /// Build a JS object
  public init<each Input: Encodable>(_ properties: repeat (String, each Input)) {
    var object = Dictionary<String, AnyEncodable>()

    for (key, value) in repeat each properties {
      object[key] = AnyEncodable(base: value)
    }

    self.rawValue = if let data = try? Self.jsonEncoder.encode(object) {
      String(decoding: data, as: UTF8.self)
    } else {
      "null"
    }
  }

  public init(_ value: some Encodable) {
    self.rawValue = if let data = try? Self.jsonEncoder.encode(value) {
      String(decoding: data, as: UTF8.self)
    } else {
      "null"
    }
  }

  @inlinable @inline(__always)
  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public subscript(dynamicMember name: String) -> Self {
    Self(rawValue: "\(self.rawValue).\(name)")
  }

  public func callAsFunction<each T: Encodable>(_ args: repeat each T) -> Self {
    var encodedValues = [String]()

    for value in repeat each args {
      let encoded = if let data = try? Self.jsonEncoder.encode(value) {
        String(decoding: data, as: UTF8.self)
      } else {
        "null"
      }

      encodedValues.append(encoded)
    }

    return Self(rawValue: self.rawValue + "(\(encodedValues.joined(separator: ", ")))")
  }

  public func callAsFunction(_ args: Expression...) -> Self {
    Self(rawValue: self.rawValue + "(\(args.map(\.rawValue).joined(separator: ", ")))")
  }
}

extension Expression {
  @inlinable @inline(__always)
  public func assign(_ expression: Self) -> Self {
    Self(rawValue: "\(self.rawValue) = \(expression)")
  }

  @inlinable @inline(__always)
  public static func * (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: "\(lhs.rawValue) * \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func *= (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: "\(lhs.rawValue) *= \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func / (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: "\(lhs.rawValue) / \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func /= (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: "\(lhs.rawValue) /= \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func + (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: "\(lhs.rawValue) + \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func += (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: "\(lhs.rawValue) += \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func - (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: "\(lhs.rawValue) - \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func -= (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: "\(lhs.rawValue) -= \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static prefix func ! (lhs: Self) -> Self {
    Self(rawValue: "!\(lhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: "\(lhs.rawValue) == \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func != (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: "\(lhs.rawValue) != \(rhs.rawValue)")
  }

  @inlinable @inline(__always)
  public static func === (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: "\(lhs.rawValue) === \(rhs.rawValue)")
  }
}

extension Expression: ExpressibleByStringLiteral {
  @inlinable @inline(__always)
  public init(stringLiteral value: String) {
    self.init(value)
  }
}

extension Expression: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: (any Encodable)...) {
    self.init(elements.map(AnyEncodable.init(base:)))
  }
}

extension Expression: ExpressibleByBooleanLiteral {
  @inlinable @inline(__always)
  public init(booleanLiteral value: BooleanLiteralType) {
    self.init(value)
  }
}

// extension Expression: ExpressibleByDictionaryLiteral {
//   public init(dictionaryLiteral elements: (String, String)...) {
//     self.init(Dictionary(elements, uniquingKeysWith: { $1 }))
//   }
// }

extension Expression: ExpressibleByFloatLiteral {
  @inlinable @inline(__always)
  public init(floatLiteral value: FloatLiteralType) {
    self.init(value)
  }
}

extension Expression: ExpressibleByIntegerLiteral {
  @inlinable @inline(__always)
  public init(integerLiteral value: IntegerLiteralType) {
    self.init(value)
  }
}

extension Expression: ExpressibleByNilLiteral {
  @inlinable @inline(__always)
  public init(nilLiteral: ()) {
    self.init(String?.none)
  }
}

extension Expression: CustomStringConvertible {
  @inlinable @inline(__always)
  public var description: String { rawValue }
}

extension HTMLBuilder {
  // Prioritize expressions from ``HTMLBuilder.buildExpression(_:HTMLString)``
  @_disfavoredOverload
  @inlinable @inline(__always)
  public static func buildExpression(_ expression: Expression) -> HTMLString {
    HTMLRaw("{{ \(expression.rawValue) }}")
  }
}

extension HTMLString.StringInterpolation {
  @inlinable @inline(__always)
  public mutating func appendInterpolation(_ expression: Expression) {
    appendInterpolation(raw: "{{ \(expression.rawValue) }}")
  }
}
