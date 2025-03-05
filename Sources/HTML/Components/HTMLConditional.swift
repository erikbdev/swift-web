public enum _HTMLConditional<TrueContent: HTML, FalseContent: HTML>: HTML {
  case trueContent(TrueContent)
  case falseContent(FalseContent)

  @_spi(Render)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    switch html {
    case .trueContent(let html): TrueContent._render(html, into: &output)
    case .falseContent(let html): FalseContent._render(html, into: &output)
    }
  }

  public var body: Never { fatalError() }
}

extension _HTMLConditional: Sendable where TrueContent: Sendable, FalseContent: Sendable {}