public enum _HTMLConditional<TrueContent: HTML, FalseContent: HTML>: HTML {
  case trueContent(TrueContent)
  case falseContent(FalseContent)

  @_spi(Render) @inlinable @inline(__always)
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