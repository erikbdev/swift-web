public struct EmptyHTML: HTML, Sendable {
  @inlinable @inline(__always)
  public init() {}

  @_spi(Render)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {}

  public var body: Never { fatalError() }
}