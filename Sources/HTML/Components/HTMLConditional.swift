public enum _HTMLConditional<TrueContent: AsyncHTML, FalseContent: AsyncHTML>: AsyncHTML {
  case trueContent(TrueContent)
  case falseContent(FalseContent)

  @inlinable @inline(__always)
  public var body: Never { fatalError() }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    switch html {
    case .trueContent(let html): try await TrueContent._render(html, into: &output)
    case .falseContent(let html): try await FalseContent._render(html, into: &output)
    }
  }
}

extension _HTMLConditional: HTML where TrueContent: HTML, FalseContent: HTML {
  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    switch html {
    case .trueContent(let html): TrueContent._render(html, into: &output)
    case .falseContent(let html): FalseContent._render(html, into: &output)
    }
  }
}

extension _HTMLConditional: Sendable where TrueContent: Sendable, FalseContent: Sendable {}