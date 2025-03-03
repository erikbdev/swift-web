import Dependencies
import OrderedCollections

extension HTML {
  public func attribute(_ name: String, value: String? = "") -> HTMLAttributes<Self> {
    HTMLAttributes(content: self, attributes: value.flatMap { [name: $0] } ?? [:])
  }

  public func attribute(_ attribute: HTMLAttribute) -> HTMLAttributes<Self> {
    HTMLAttributes(content: self, attributes: attribute.value.flatMap { [attribute.name: $0] } ?? [:])
  }
}

public struct HTMLAttribute {
  public let name: String
  public let value: String?

  public init(name: String = #function, value: String? = "") {
    self.name = name
    self.value = value
  }

  public func callAsFunction(_ value: String? = "") -> Self {
    Self(name: name, value: value)
  }
}

extension HTMLAttribute {
  public static var `class`: HTMLAttribute { HTMLAttribute() }
  public static var style: HTMLAttribute { HTMLAttribute() }
  public static var id: HTMLAttribute { HTMLAttribute() }
}

public struct HTMLAttributes<Content: HTML>: HTML {
  let content: Content
  var attributes: OrderedDictionary<String, String>

  public func attribute(_ name: String, value: String? = "" ) -> Self {
    var copy = self
    copy.attributes[name] = value
    return copy
  }

  public func attribute(_ attribute: HTMLAttribute) -> Self {
    var copy = self
    copy.attributes[attribute.name] = attribute.value
    return copy
  }

  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self, 
    into output: inout Output
  ) {
    withDependencies {
      $0.allAttributes.merge(html.attributes, uniquingKeysWith: { $0 + $1 })
    } operation: {
      Content._render(html.content, into: &output)      
    }
  }

  public var body: Never { fatalError() }
}

extension DependencyValues {
  var allAttributes: OrderedDictionary<String, String> {
    get { self[HTMLAttributeKey.self] }
    set { self[HTMLAttributeKey.self] = newValue }
  }
}

private enum HTMLAttributeKey: DependencyKey {
  static var liveValue: OrderedDictionary<String, String> { [:] }
  static var testValue: OrderedDictionary<String, String> { [:] }
}