public struct HTMLComment: HTML, Sendable {
  @usableFromInline
  let bytes: ContiguousArray<UInt8>

  @inlinable @inline(__always)
  public init(_ comment: consuming String) {
    self.init(comment.utf8)
  }

  @inlinable @inline(__always)
  public init(_ comment: consuming some Sequence<UInt8>) {
    self.bytes = ContiguousArray(comment)
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming HTMLComment,
    into output: inout Output
  ) {
    [0x3C, 0x21, 0x2D, 0x2D].withUnsafeBufferPointer { 
      output.write($0)  // <!--      
    }
    HTMLString._render(HTMLString(html.bytes, escape: true), into: &output)  // comment
    [0x2D, 0x2D, 0x3E].withUnsafeBufferPointer {
      output.write($0)  // -->
    }
  }

  public var body: Never { fatalError() }
}
