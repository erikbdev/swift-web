public struct HTMLTuple<each Content: HTML>: HTML {
  @usableFromInline
  let content: (repeat each Content)

  @inlinable @inline(__always)
  public init(_ content: repeat each Content) {
    self.content = (repeat each content)
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    func render<T: HTML>(_ html: T) {
      T._render(html, into: &output)
    }

    repeat render(each html.content)
  }

  public var body: Never { fatalError() }
}

extension HTMLTuple: Sendable where repeat each Content: Sendable {}