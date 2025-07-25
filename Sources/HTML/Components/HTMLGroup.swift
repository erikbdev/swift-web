public struct HTMLGroup<Content: AsyncHTML>: AsyncHTML {
  @usableFromInline
  let content: Content

  @inlinable @inline(__always)
  public init(@HTMLBuilder content: () -> Content) {
    self.content = content()
  }

  @inlinable @inline(__always)
  public var body: Content { content }
}

extension HTMLGroup: HTML where Content: HTML {}