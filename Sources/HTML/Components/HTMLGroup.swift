public struct HTMLGroup<Content: HTML>: HTML {
  @usableFromInline
  let content: Content

  @inlinable @inline(__always)
  public init(@HTMLBuilder content: () -> Content) {
    self.content = content()
  }

  @inlinable @inline(__always)
  public var body: some HTML { content }
}