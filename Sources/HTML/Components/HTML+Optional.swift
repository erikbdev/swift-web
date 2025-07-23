extension Optional: HTML where Wrapped: HTML {
  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    if case .some(let html) = html {
      Wrapped._render(html, into: &output)
    }
  }

  public var body: Never { fatalError() }
}

extension Optional: Sendable where Wrapped: Sendable {}