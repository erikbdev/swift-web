import Dependencies

public protocol HTMLDocument: HTML {
  associatedtype Head: HTML

  @HTMLBuilder var head: Head { get }
}

extension HTMLDocument {
  public static func _render<Output: HTMLByteStream>(
    _ document: consuming Self,
    into output: inout Output
  ) {
    @Dependency(\.ssg) var ssg

    let documentBody: _HTMLConditional<_HTMLBytes, Body>
    let stylesheet: String

    if let ssg {
      var bodyBytes = _HTMLBytes()
      Body._render(document.body, into: &bodyBytes)
      stylesheet = ssg.stylesheet()
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

private struct _HTMLBytes: HTML, Sendable, HTMLByteStream {
  var bytes: ContiguousArray<UInt8> = []

  mutating func write(_ byte: UInt8) {
    self.bytes.append(byte)
  }

  mutating func write(_ bytes: consuming some Collection<UInt8>) {
    self.bytes.append(contentsOf: bytes)
  }

  static func _render<Output: HTMLByteStream>(
    _ html: consuming _HTMLBytes,
    into output: inout Output
  ) {
    html.bytes.withUnsafeBufferPointer {
      output.write($0)
    }
  }

  var body: Never { fatalError() }
}

extension HTMLBuilder {
  fileprivate static func render<Output: HTMLByteStream, Content: HTML>(
    into output: inout Output,
    @HTMLBuilder content: () -> Content
  ) {
    Content._render(content(), into: &output)
  }
}