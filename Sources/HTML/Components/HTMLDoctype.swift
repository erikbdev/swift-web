public struct HTMLDoctype: HTML {
  @inlinable @inline(__always)
  public init() {}

  public var body: HTMLString {
    HTMLRaw("<!doctype html>")
  }
}
