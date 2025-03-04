public struct AnyHTML: HTML {
  @usableFromInline
  let base: any HTML

  @inlinable @inline(__always)
  public init(_ base: some HTML) {
    self.base = base
  }

  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    func render<T: HTML>(_ html: T) {
      T._render(html, into: &output)
    }
    render(html.base)
  }

  public var body: Never { fatalError() }
}
