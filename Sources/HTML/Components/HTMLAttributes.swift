import Dependencies
import OrderedCollections

extension HTML {
  public func attribute(
    _ name: String, 
    value: String? = "", 
    mergeMode: HTMLAttribute.MergeMode = .replaceValue
  ) -> HTMLAttributes<Self> {
    HTMLAttributes(
      content: self, 
      attributes: [HTMLAttribute(name: name, value: value, mergeMode: mergeMode)]
    )
  }

  public func attribute(_ attribute: HTMLAttribute) -> HTMLAttributes<Self> {
    HTMLAttributes(
      content: self, 
      attributes: [attribute]
    )
  }
}

public struct HTMLAttributes<Content: HTML>: HTML {
  let content: Content
  var attributes: OrderedSet<HTMLAttribute>

  @usableFromInline
  init(
    content: Content,
    attributes: OrderedSet<HTMLAttribute>
  ) {
    self.content = content
    self.attributes = attributes
  }

  public func attribute(
    _ name: String, 
    value: String? = "", 
    mergeMode: HTMLAttribute.MergeMode = .replaceValue
  ) -> Self {
    var copy: HTMLAttributes<Content> = self
    copy.attributes.append(HTMLAttribute(name: name, value: value, mergeMode: mergeMode))
    return copy
  }

  public func attribute(_ attribute: HTMLAttribute) -> Self {
    var copy = self
    copy.attributes.append(attribute)
    return copy
  }

  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self, 
    into output: inout Output
  ) {
    withDependencies {
      for attr in html.attributes {
        $0.allAttributes[attr.name] = switch ($0.allAttributes[attr.name], attr.value, attr.mergeMode) {
          case (.none, let newValue, .ignoreIfSet):
            newValue
          case (_, let newValue, .replaceValue):
            newValue
          case (.none, .some(let newValue), .mergeValue):
            newValue
          case (.some(let oldValue), .some(let newValue), .mergeValue):
            oldValue.isEmpty ? newValue : "\(oldValue) \(newValue)"
          case (let oldValue, _, _): oldValue
        }
      }
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
