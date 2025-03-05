public protocol HTML {
  /// The type of the HTML content this body represents.
  associatedtype Body: HTML

  /// The HTML body of this componrnt.
  @HTMLBuilder var body: Self.Body { get }

  @_spi(Render)
  static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  )
}

extension HTML {
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    Body._render(html.body, into: &output)
  }
}

extension Never: HTML {
  public var body: Never { fatalError() }

  @_spi(Render) @inlinable @inline(__always)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
  }
}
