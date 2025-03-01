public struct HTMLTuple<each Content: HTML>: HTML {
  let content: (repeat each Content)

  public var body: Never { fatalError() }

  @inline(__always)
  public init(_ content: repeat each Content) {
    self.content = (repeat each content)
  }

  @_spi(Render) @inline(__always)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self, 
    into output: inout Output
  ) {
    func render<T: HTML>(_ html: T) {
      T._render(html, into: &output)
    }

    repeat render(each html.content)
  }
}