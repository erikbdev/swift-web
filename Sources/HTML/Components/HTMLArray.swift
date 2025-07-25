public struct _HTMLArray<Element: AsyncHTML>: AsyncHTML {
  @usableFromInline
  let elements: [Element]

  public var body: Never { fatalError() }

  @inlinable @inline(__always)
  init(elements: [Element]) {
    self.elements = elements
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    for element in html.elements {
      try await Element._render(element, into: &output)
    }
  }
}

extension _HTMLArray: HTML where Element: HTML {
  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self, 
    into output: inout Output
  ) {
    for element in html.elements {
      Element._render(element, into: &output)
    }
  }
}

extension _HTMLArray: Sendable where Element: Sendable {}