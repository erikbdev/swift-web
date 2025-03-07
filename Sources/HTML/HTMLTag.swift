import OrderedCollections

public struct HTMLTag: Hashable, Sendable, ExpressibleByStringLiteral {
  public let rawValue: String

  @inlinable @inline(__always)
  public init(_ rawValue: String) {
    self.rawValue = rawValue
  }

  @inlinable @inline(__always)
  public init(stringLiteral value: StringLiteralType) {
    self.init(value)
  }

  @inlinable @inline(__always)
  public func callAsFunction(_ attributes: HTMLAttribute...) -> HTMLAttributes<HTMLElement<EmptyHTML>> {
    self.callAsFunction(attributes: attributes)
  }

  @inlinable @inline(__always)
  public func callAsFunction(attributes: [HTMLAttribute]) -> HTMLAttributes<HTMLElement<EmptyHTML>> {
    HTMLAttributes(
      content: HTMLElement(tag: rawValue, content: EmptyHTML.init),
      attributes: .init(attributes)
    )
  }

  @inlinable @inline(__always)
  public func callAsFunction<Content: HTML>(
    _ attributes: HTMLAttribute...,
    @HTMLBuilder content: () -> Content
  ) -> HTMLAttributes<HTMLElement<Content>> {
    self.callAsFunction(attributes: attributes, content: content)
  }

  @inlinable @inline(__always)
  public func callAsFunction<Content: HTML>(
    attributes: [HTMLAttribute],
    @HTMLBuilder content: () -> Content
  ) -> HTMLAttributes<HTMLElement<Content>> {
    HTMLAttributes(
      content: HTMLElement(tag: rawValue, content: content),
      attributes: .init(attributes)
    )
  }
}

public struct HTMLVoidTag: Hashable, Sendable, ExpressibleByStringLiteral {
  public let rawValue: String

  @inlinable @inline(__always)
  public init(stringLiteral value: StringLiteralType) {
    self.init(value)
  }

  @inlinable @inline(__always)
  public init(_ tag: String) {
    rawValue = tag
  }

  @inlinable @inline(__always)
  public func callAsFunction(_ attributes: HTMLAttribute...) -> HTMLAttributes<HTMLVoidElement> {
    self.callAsFunction(attributes: attributes)
  }

  @inlinable @inline(__always)
  public func callAsFunction(attributes: [HTMLAttribute]) -> HTMLAttributes<HTMLVoidElement> {
    HTMLAttributes(
      content: HTMLVoidElement(tag: rawValue),
      attributes: .init(attributes)
    )
  }
}

public typealias tag = HTMLTag

public var a: HTMLTag { #function }
public var abbr: HTMLTag { #function }
public var acronym: HTMLTag { #function }
public var address: HTMLTag { #function }
public var area: HTMLVoidTag { #function }
public var article: HTMLTag { #function }
public var aside: HTMLTag { #function }
public var audio: HTMLTag { #function }
public var b: HTMLTag { #function }
public var base: HTMLVoidTag { #function }
public var bdi: HTMLTag { #function }
public var bdo: HTMLTag { #function }
public var blockquote: HTMLTag { #function }
@available(*, deprecated, message: "Use `HTMLDocument.body` instead")
public var body: HTMLTag { #function }
public var br: HTMLVoidTag { #function }
public var button: HTMLTag { #function }
public var canvas: HTMLTag { #function }
public var caption: HTMLTag { #function }
public var cite: HTMLTag { #function }
public var code: HTMLTag { #function }
public var col: HTMLVoidTag { #function }
public var colgroup: HTMLTag { #function }
public var data: HTMLTag { #function }
public var datalist: HTMLTag { #function }
public var dd: HTMLTag { #function }
public var del: HTMLTag { #function }
public var details: HTMLTag { #function }
public var dfn: HTMLTag { #function }
public var dialog: HTMLTag { #function }
public var div: HTMLTag { #function }
public var dl: HTMLTag { #function }
public var dt: HTMLTag { #function }
public var em: HTMLTag { #function }
public var embed: HTMLVoidTag { #function }
public var fieldset: HTMLTag { #function }
public var figcaption: HTMLTag { #function }
public var figure: HTMLTag { #function }
public var footer: HTMLTag { #function }
public var form: HTMLTag { #function }
public var h1: HTMLTag { #function }
public var h2: HTMLTag { #function }
public var h3: HTMLTag { #function }
public var h4: HTMLTag { #function }
public var h5: HTMLTag { #function }
public var h6: HTMLTag { #function }
@available(*, deprecated, message: "Use `HTMLDocument.head` instead")
public var head: HTMLTag { #function }
public var header: HTMLTag { #function }
public var hgroup: HTMLTag { #function }
public var hr: HTMLVoidTag { #function }
public var html: HTMLTag { #function }
public var i: HTMLTag { #function }
public var iframe: HTMLTag { #function }
public var img: HTMLVoidTag { #function }
public var input: HTMLVoidTag { #function }
public var ins: HTMLTag { #function }
public var kbd: HTMLTag { #function }
public var label: HTMLTag { #function }
public var legend: HTMLTag { #function }
public var li: HTMLTag { #function }
public var link: HTMLVoidTag { #function }
public var main: HTMLTag { #function }
public var map: HTMLTag { #function }
public var mark: HTMLTag { #function }
public var meta: HTMLVoidTag { #function }
public var meter: HTMLTag { #function }
public var nav: HTMLTag { #function }
public var noscript: HTMLTag { #function }
public var object: HTMLTag { #function }
public var ol: HTMLTag { #function }
public var optgroup: HTMLTag { #function }
public var option: HTMLTag { #function }
public var output: HTMLTag { #function }
public var p: HTMLTag { #function }
public var param: HTMLVoidTag { #function }
public var picture: HTMLTag { #function }
public var pre: HTMLTag { #function }
public var progress: HTMLTag { #function }
public var q: HTMLTag { #function }
public var rp: HTMLTag { #function }
public var rt: HTMLTag { #function }
public var ruby: HTMLTag { #function }
public var s: HTMLTag { #function }
public var samp: HTMLTag { #function }
public func script(
  _ attributes: HTMLAttribute..., 
  @StringBuilder stript stringValue: () -> String = { "" }
) -> HTMLAttributes<HTMLElement<HTMLString>> {
  HTMLAttributes(
    content: HTMLElement(tag: "script") {
      HTMLString(raw: stringValue())
    },
    attributes: OrderedSet(attributes)
  )
}
public var section: HTMLTag { #function }
public var select: HTMLTag { #function }
public var small: HTMLTag { #function }
public var source: HTMLVoidTag { #function }
public var span: HTMLTag { #function }
public var strong: HTMLTag { #function }
public var style: HTMLTag { #function }
public func style(
  _ attributes: HTMLAttribute..., 
  @StringBuilder style stringValue: () -> String = { "" }
) -> HTMLAttributes<HTMLElement<HTMLString>> {
  HTMLAttributes(
    content: HTMLElement(tag: "script") {
      HTMLString(raw: stringValue())
    },
    attributes: OrderedSet(attributes)
  )
}
public var sub: HTMLTag { #function }
public var summary: HTMLTag { #function }
public var sup: HTMLTag { #function }
public var svg: HTMLTag { #function }
public var table: HTMLTag { #function }
public var tbody: HTMLTag { #function }
public var td: HTMLTag { #function }
public var template: HTMLTag { #function }
public var textarea: HTMLTag { #function }
public var tfoot: HTMLTag { #function }
public var th: HTMLTag { #function }
public var thead: HTMLTag { #function }
public var time: HTMLTag { #function }
public var title: HTMLTag { #function }
public var tr: HTMLTag { #function }
public var track: HTMLVoidTag { #function }
public var u: HTMLTag { #function }
public var ul: HTMLTag { #function }
public var `var`: HTMLTag { #function }
public var video: HTMLTag { #function }
public var wbr: HTMLVoidTag { #function }
