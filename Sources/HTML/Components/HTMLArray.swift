public struct _HTMLArray<Element: HTML>: HTML {
  @usableFromInline
  let elements: [Element]

  @inlinable @inline(__always)
  init(elements: [Element]) {
    self.elements = elements
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self, 
    into output: inout Output
  ) {
    for element in html.elements {
      Element._render(element, into: &output)
    }
  }

  public var body: Never { fatalError() }
}

extension _HTMLArray: Sendable where Element: Sendable {}