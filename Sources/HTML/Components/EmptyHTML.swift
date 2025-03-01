public struct EmptyHTML: HTML {

  public var body: Never { fatalError() }

  @inlinable @inline(__always)
  public init() {}

  @_spi(Render) @inlinable @inline(__always)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self, 
    into output: inout Output
  ) {}
}