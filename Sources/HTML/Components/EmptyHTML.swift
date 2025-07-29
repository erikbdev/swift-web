public struct EmptyHTML: HTML, Sendable {
  public var body: Never { fatalError() }

  @inlinable @inline(__always)
  public init() {}

  @_spi(Render)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {}

  @_spi(Render)
  public static func _render<Output: AsyncHTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {}
}