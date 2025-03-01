public struct HTMLDoctype: HTML {
  @inlinable @inline(__always)
  public init() {}

  public var body: some HTML {
    HTMLRaw("<!doctype html>")
  }
}