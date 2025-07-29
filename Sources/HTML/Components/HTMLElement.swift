import Dependencies
import OrderedCollections
import struct Foundation.Data

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
  public init<Awaitable: AsyncHTML>(
    tag: String = #function, 
    @HTMLBuilder content: @escaping @Sendable () async throws -> Awaitable
  ) where Content == AsyncHTMLContent<Awaitable> {
    self.tag = tag
    self.content = AsyncHTMLContent(content: content)
  }

  @_spi(Render)
  public static func _render<Output: AsyncHTMLOutputStream>(
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
    var buffer = Data()
    buffer.append(0x3C)  // <
    buffer.append(0x2F)  // /
    buffer.append(contentsOf: html.tag.utf8)  // <tag-name>
    buffer.append(0x3E)  // >
    try await output.write(buffer)
  }
}

extension HTMLElement: HTML where Content: HTML {
  @_spi(Render)
  public static func _render<Output: HTMLOutputStream>(
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
    var buffer = Data()
    buffer.append(0x3C)  // <
    buffer.append(0x2F)  // /
    buffer.append(contentsOf: html.tag.utf8)  // <tag-name>
    buffer.append(0x3E)  // >
    output.write(buffer)
  }
}

public struct HTMLVoidElement: HTML, Sendable {
  public let tag: String

  public var body: Never { fatalError() }

  @inlinable @inline(__always)
  public init(tag: String) {
    self.tag = tag
  }

  @_spi(Render)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self,
    into writer: inout Output
  ) {
    var buffer = Data()
    html.writeBytes(&buffer)
    writer.write(buffer)
  }

  @_spi(Render)
  public static func _render<Output: AsyncHTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    var buffer = Data()
    html.writeBytes(&buffer)
    try await output.write(buffer)
  }

  private func writeBytes(_ buffer: inout Data) {
    @Dependency(\.htmlContext) var context
    buffer.append(0x3C)  // <
    buffer.append(contentsOf: self.tag.utf8)  // tag-name
    for (name, value) in context.attributes {
      buffer.append(0x20)  // space
      buffer.append(contentsOf: name.utf8)  // <name>
      if !value.isEmpty {
        buffer.append(0x3D)  // =
        buffer.append(0x22)  // "
        for byte in value.utf8 {
          switch byte {
          case 0x26:  // &
            buffer.append(contentsOf: "&amp;".utf8)
          case 0x22:  // "
            buffer.append(contentsOf: "&quot;".utf8)
          case 0x27:  // '
            buffer.append(contentsOf: "&#39;".utf8)
          default:
            buffer.append(byte)
          }
        }
        buffer.append(0x22)  // "
      }
    }
    buffer.append(0x3E)  // >
  }
}

extension HTMLElement: Sendable where Content: Sendable {}