import Dependencies

public protocol HTMLDocument: HTML {
  associatedtype Head: HTML

  @HTMLBuilder var head: Head { get }

  var ssg: StyleSheetGenerator? { get }
}

extension HTMLDocument {
  public var ssg: StyleSheetGenerator? { .class }

  @_spi(Render)
  public static func _render<Output: HTMLOutputStream>(
    _ document: consuming Self,
    into output: inout Output
  ) {
    let documentBody: _HTMLConditional<_HTMLBytes, Body>
    let stylesheet: String

    if let ssg = document.ssg {
      var bodyBytes = _HTMLBytes()
      stylesheet = withDependencies {
        $0.ssg = ssg
      } operation: {
        @Dependency(\.ssg) var generator
        Body._render(document.body, into: &bodyBytes)
        return generator?.stylesheet() ?? ""
      }
      documentBody = .trueContent(bodyBytes)
    } else {
      stylesheet = ""
      documentBody = .falseContent(document.body)
    }

    HTMLBuilder.render(into: &output) {
      HTMLDoctype()
      html {
        tag("head") {
          document.head

          if !stylesheet.isEmpty {
            style {
              HTMLRaw(stylesheet)
            }
          }
        }

        tag("body") {
          documentBody
        }
      }
    }
  }
}

private struct _HTMLBytes: HTML, Sendable, HTMLOutputStream {
  var bytes: ContiguousArray<UInt8> = []

  mutating func write(_ byte: UInt8) {
    self.bytes.append(byte)
  }

  mutating func write(_ bytes: consuming some Collection<UInt8>) {
    self.bytes.append(contentsOf: bytes)
  }

  static func _render<Output: HTMLOutputStream>(
    _ html: consuming _HTMLBytes,
    into output: inout Output
  ) {
    output.write(html.bytes)
  }

  var body: Never { fatalError() }
}

extension HTMLBuilder {
  fileprivate static func render<Output: HTMLOutputStream, Content: HTML>(
    into output: inout Output,
    @HTMLBuilder content: () -> Content
  ) {
    Content._render(content(), into: &output)
  }
}