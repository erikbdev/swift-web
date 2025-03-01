public protocol HTMLDocument: HTML {
  associatedtype Head: HTML

  @HTMLBuilder var head: Head { get }
}

extension HTMLDocument {
  public static func _render<Output: HTMLOutputStream>(
    _ content: consuming Self, 
    into output: inout Output
  ) {
    HTMLBuilder.render(into: &output) {
      HTMLDoctype()
      html {
        tag("head") {
          content.head
        }
        tag("body") {
          content.body
        }
      }
    }
  }
}

private extension HTMLBuilder {
  static func render<Output: HTMLOutputStream, Content: HTML>(
    into output: inout Output,
    @HTMLBuilder _ content: () -> Content
  ) {
    Content._render(content(), into: &output)
  }
}