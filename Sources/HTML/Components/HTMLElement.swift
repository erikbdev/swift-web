import Dependencies
import OrderedCollections

public struct HTMLElement<Content: AsyncHTML>: AsyncHTML {
  public let tag: String

  @usableFromInline
  let content: Content

  public var body: Never { fatalError() }

  @inlinable @inline(__always)
  public init(
    tag: String = #function, 
    @HTMLBuilder content: () -> Content
  ) {
    self.tag = tag
    self.content = content()
  }

  @inlinable @inline(__always)
  public init<AwaitableContent: AsyncHTML>(
    tag: String = #function, 
    @HTMLBuilder content: @escaping @Sendable () async throws -> AwaitableContent
  ) where Content == AsyncHTMLContent<AwaitableContent> {
    self.tag = tag
    self.content = AsyncHTMLContent(content: content)
  }

  @_spi(Render)
  @inlinable @inline(__always)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    try await HTMLVoidElement._render(
      HTMLVoidElement(tag: html.tag),
      into: &output
    )
    try await withDependencies {
      $0.htmlContext.attributes.removeAll()
      $0.htmlContext.depth += 1
    } operation: {
      try await Content._render(html.content, into: &output)
    }
    output.write(0x3C)  // <
    output.write(0x2F)  // /
    output.write(html.tag.utf8)  // <tag-name>
    output.write(0x3E)  // >
  }
}

extension HTMLElement: HTML where Content: HTML {
  @_spi(Render)
  @inlinable @inline(__always)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    HTMLVoidElement._render(
      HTMLVoidElement(tag: html.tag),
      into: &output
    )
    withDependencies {
      $0.htmlContext.attributes.removeAll()
      $0.htmlContext.depth += 1
    } operation: {
      Content._render(html.content, into: &output)
    }
    output.write(0x3C)  // <
    output.write(0x2F)  // /
    output.write(html.tag.utf8)  // <tag-name>
    output.write(0x3E)  // >
  }
}

extension HTMLElement: Sendable where Content: Sendable {}

public struct HTMLVoidElement: HTML, Sendable {
  public let tag: String

  public var body: Never { fatalError() }

  @inlinable @inline(__always)
  public init(tag: String) {
    self.tag = tag
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    @Dependency(\.htmlContext) var context
    output.write(0x3C)  // <
    output.write(html.tag.utf8)  // tag-name
    for (name, value) in context.attributes {
      output.write(0x20)  // space
      output.write(name.utf8)  // <name>
      if !value.isEmpty {
        output.write(0x3D)  // =
        output.write(0x22)  // "
        for byte in value.utf8 {
          switch byte {
          case 0x26:  // &
            output.write("&amp;".utf8)
          case 0x22:  // "
            output.write("&quot;".utf8)
          case 0x27:  // '
            output.write("&#39;".utf8)
          default:
            output.write(byte)
          }
        }
        output.write(0x22)  // "
      }
    }
    output.write(0x3E)  // >
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    func _render(_ html: consuming Self) {
      Self._render(html, into: &output)
    }
    _render(html)
  }
}
