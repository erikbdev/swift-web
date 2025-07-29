public struct HTMLComment: HTML, Sendable {
  public let text: String

  public var body: Never { fatalError() }

  @inlinable
  public init(_ text: consuming String) {
    self.text = text
  }

  private static let start: [UInt8] = [0x3C, 0x21, 0x2D, 0x2D]  // <!--
  private static let end: [UInt8] = [0x2D, 0x2D, 0x3E]  // -->

  @_spi(Render)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming HTMLComment,
    into output: inout Output
  ) {
    output.write(start)
    HTMLString._render(HTMLString(html.text), into: &output)  // comment
    output.write(end) 
  }

  @_spi(Render)
  public static func _render<Output: AsyncHTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    try await output.write(start)
    try await HTMLString._render(HTMLString(html.text), into: &output)  // comment
    try await output.write(end)
  }
}
