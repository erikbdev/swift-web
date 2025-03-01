public struct HTMLComment: HTML {
  let bytes: ContiguousArray<UInt8>

  public var body: Never { fatalError() }

  @inlinable @inline(__always)
  public init(_ comment: consuming String) {
    self.init(comment.utf8)
  }

  @inline(__always)
  public init(_ comment: consuming some Sequence<UInt8>) {
    self.bytes = ContiguousArray(comment)
  }

  @_spi(Render) @inline(__always)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming HTMLComment, 
    into output: inout Output
  ) {
    output.write([0x3C, 0x21, 0x2D, 0x2D])  // <!--
    HTMLString._render(HTMLString(html.bytes, escape: true), into: &output)  // comment
    output.write([0x2D, 0x2D, 0x3E])        // -->
  }
}