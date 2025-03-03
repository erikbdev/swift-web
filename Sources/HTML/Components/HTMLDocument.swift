import Dependencies

public protocol HTMLDocument: HTML {
  associatedtype Head: HTML

  @HTMLBuilder var head: Head { get }
}

extension HTMLDocument {
  public static func _render<Output: HTMLOutputStream>(
    _ document: consuming Self,
    stylesheet: String,
    into output: inout Output
  ) {
    var bodyBytes = _HTMLBytes()

    let stylesheet = withDependencies {
      if !$0.isSSGSet {
        $0.styleSheetGenerator = .class
      }
    } operation: {
      @Dependency(\.styleSheetGenerator) var generator
      Body._render(document.body, into: &bodyBytes)
      return generator?.stylesheet()
    }

    HTMLBuilder.render(into: &output) {
      HTMLDoctype()
      html {
        tag("head") {
          document.head

          if let stylesheet, !stylesheet.isEmpty {
            style {
              HTMLRaw(stylesheet)
            }
          }
        }

        tag("body") {
          bodyBytes
        }
      }
    }
  }
}

private struct _HTMLBytes: HTML, HTMLOutputStream {
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

private extension HTMLBuilder {
  static func render<Output: HTMLOutputStream, Content: HTML>(
    into output: inout Output,
    @HTMLBuilder content: () -> Content
  ) {
    Content._render(content(), into: &output)
  }
}