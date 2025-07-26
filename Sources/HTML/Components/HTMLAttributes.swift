import Dependencies
import OrderedCollections

public struct HTMLAttributes<Content: AsyncHTML>: AsyncHTML {
  @usableFromInline
  let content: Content

  @usableFromInline
  var attributes: OrderedSet<HTMLAttribute>

  public var body: Never { fatalError() }

  @inlinable @inline(__always)
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
    var copy = self
    copy.attributes.append(HTMLAttribute(name: name, value: value, mergeMode: mergeMode))
    return copy
  }

  public func attribute(_ attribute: HTMLAttribute) -> Self {
    var copy = self
    copy.attributes.append(attribute)
    return copy
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    try await withDependencies {
      for attr in html.attributes {
        $0.htmlContext.attributes[attr.name] =
          switch ($0.htmlContext.attributes[attr.name], attr.value, attr.mergeMode) {
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
      try await Content._render(html.content, into: &output)
    }
  }
}

extension HTMLAttributes: HTML where Content: HTML {
  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    withDependencies {
      for attr in html.attributes {
        $0.htmlContext.attributes[attr.name] =
          switch ($0.htmlContext.attributes[attr.name], attr.value, attr.mergeMode) {
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
}

extension HTMLAttributes: Sendable where Content: Sendable {}

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