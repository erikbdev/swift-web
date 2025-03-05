import Dependencies
import OrderedCollections

public struct HTMLElement<Content: HTML>: HTML {
  public let tag: String

  @usableFromInline
  let content: Content

  @inlinable @inline(__always)
  public init(tag: String, @HTMLBuilder content: () -> Content) {
    self.tag = tag
    self.content = content()
  }

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
      $0.allAttributes.removeAll()
    } operation: {
      Content._render(html.content, into: &output)
    }
    output.write(0x3C)  // <
    output.write(0x2F)  // /
    output.write(html.tag.utf8)  // <tag-name>
    output.write(0x3E)  // >
  }

  public var body: Never { fatalError() }
}

extension HTMLElement: Sendable where Content: Sendable {}

public struct HTMLVoidElement: HTML, Sendable {
  public let tag: String

  @inlinable @inline(__always)
  public init(tag: String) {
    self.tag = tag
  }

  @_spi(Render)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    @Dependency(\.allAttributes) var allAttributes
    // @Dependency(\.htmlContext) var context

    output.write(0x3C)  // <
    output.write(html.tag.utf8)  // tag-name
    for (name, value) in allAttributes {
      output.write(0x20)  // space
      output.write(name.utf8)  // <name>
      if !value.isEmpty {
        output.write(0x3D)  // =
        output.write(0x22)  // "
        for byte in value.utf8 {
          switch byte {
          case 0x28:  // &
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

  public var body: Never { fatalError() }
}
