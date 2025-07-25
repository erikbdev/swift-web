public struct HTMLComment: HTML, Sendable {
  @usableFromInline
  let bytes: ContiguousArray<UInt8>

  public var body: Never { fatalError() }

  @inlinable @inline(__always)
  public init(_ comment: consuming String) {
    self.init(comment.utf8)
  }

  @inlinable @inline(__always)
  public init(_ comment: consuming some Sequence<UInt8>) {
    self.bytes = ContiguousArray(comment)
  }

  private static let start: [UInt8] = [0x3C, 0x21, 0x2D, 0x2D]  // <!--
  private static let end: [UInt8] = [0x2D, 0x2D, 0x3E]  // -->

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming HTMLComment,
    into output: inout Output
  ) {
    output.write(start)
    HTMLString._render(HTMLString(html.bytes, escape: true), into: &output)  // comment
    output.write(end) 
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    output.write(start)
    try await HTMLString._render(HTMLString(html.bytes, escape: true), into: &output)  // comment
    output.write(end)
  }
}
