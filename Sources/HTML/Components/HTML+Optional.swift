extension Optional: HTML where Wrapped: HTML {
  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
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

extension Optional: Sendable where Wrapped: Sendable {}