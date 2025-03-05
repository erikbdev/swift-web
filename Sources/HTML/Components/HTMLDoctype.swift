public struct HTMLDoctype: HTML, Sendable {
  @inlinable @inline(__always)
  public init() {}

  public var body: HTMLString {
    HTMLRaw("<!doctype html>")
  }
}