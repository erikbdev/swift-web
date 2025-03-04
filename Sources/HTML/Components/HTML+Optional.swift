extension Optional: HTML where Wrapped: HTML {
  @_spi(Render) @inlinable @inline(__always)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    switch html {
    case let .some(html): Wrapped._render(html, into: &output)
    case .none: break
    }
  }

  public var body: Never { fatalError() }
}
