import Dependencies

public protocol HTMLDocument: AsyncHTML where Body: AsyncHTML {
  associatedtype Head: AsyncHTML

  @HTMLBuilder var head: Head { get }
}

extension HTMLDocument {
  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ document: consuming Self,
    into output: inout Output
  ) async throws {
    @Dependency(\.htmlContext) var context

    let documentBody: _HTMLConditional<_HTMLBytes, Body>
    let stylesheet: String

    if let ssg = context.styles {
      var bodyBytes = _HTMLBytes()
      try await Body._render(document.body, into: &bodyBytes)
      stylesheet = ssg.stylesheet()
      documentBody = .trueContent(bodyBytes)
    } else {
      stylesheet = ""
      documentBody = .falseContent(document.body)
    }

    try await HTMLGroup {
      HTMLDoctype()
      tag("html") {
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
    .render(into: &output)
  }
}

extension HTMLDocument where Head: HTML, Body: HTML {
  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ document: consuming Self,
    into output: inout Output
  ) {
    @Dependency(\.htmlContext) var context

    let documentBody: _HTMLConditional<_HTMLBytes, Body>
    let stylesheet: String

    if let ssg = context.styles {
      var bodyBytes = _HTMLBytes()
      Body._render(document.body, into: &bodyBytes)
      stylesheet = ssg.stylesheet()
      documentBody = .trueContent(bodyBytes)
    } else {
      stylesheet = ""
      documentBody = .falseContent(document.body)
    }

    HTMLGroup {
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
    .render(into: &output)
  }
}

private struct _HTMLBytes: HTML, Sendable, HTMLByteStream {
  var bytes: ContiguousArray<UInt8> = []

  mutating func write(_ byte: UInt8) {
    self.bytes.append(byte)
  }

  mutating func write(_ bytes: consuming some Sequence<UInt8>) {
    self.bytes.append(contentsOf: bytes)
  }

  static func _render<Output: HTMLByteStream>(
    _ html: consuming _HTMLBytes,
    into output: inout Output
  ) {
    output.write(html.bytes)
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    output.write(html.bytes)
  }

  var body: Never { fatalError() }
}
