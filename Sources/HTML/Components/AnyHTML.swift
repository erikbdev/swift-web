public struct AnyHTML: HTML {
  @usableFromInline
  let base: any HTML

  @inlinable @inline(__always)
  public init(_ base: some HTML) {
    if let base = base as? AnyHTML {
      self = base
    } else {
      self.base = base
    }
  }

  @_spi(Render)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    func render<T: HTML>(_ html: T) {
      T._render(html, into: &output)
    }
    render(html.base)
  }

  public var body: Never { fatalError() }
}

public struct _SendableAnyHTML: HTML, Sendable {
  @usableFromInline
  var base: any HTML & Sendable

  @inlinable @inline(__always)
  public init(_ base: some HTML & Sendable) {
    if let base = base as? _SendableAnyHTML {
      self = base
    } else {
      self.base = base
    }
  }

  @_spi(Render)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    func render<T: HTML>(_ html: T) {
      T._render(html, into: &output)
    }
    render(html.base)
  }

  public var body: Never { fatalError() }
}