import Markdown

public struct HTMLMarkdown: HTML, Sendable, ExpressibleByStringLiteral {
  public let body: _SendableAnyHTML

  public init(_ markdown: String) {
    var converter = HTMLMarkdownConverter()
    self.body = converter.visit(Document(parsing: markdown))
  }

  @inlinable @inline(__always)
  public init(_ markdown: () -> String) {
    self.init(markdown())
  }

  @inlinable @inline(__always)
  public init(stringLiteral value: StringLiteralType) {
    self.init(value)
  }
}

private struct HTMLMarkdownConverter: MarkupVisitor {
  typealias Result = _SendableAnyHTML

  @HTMLBuilder
  mutating func defaultVisit(
    _ markup: any Markup
  ) -> Result {
    for child in markup.children {
      visit(child)
    }
  }

  @HTMLBuilder
  mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> Result {
    // switch blockDirective
    for child in blockDirective.children {
      visit(child)
    }
  }

  @HTMLBuilder
  mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Result {
    let aside = Aside(blockQuote)
    blockquote {
      for child in aside.content {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
    let language = codeBlock.language.map {
      let languageInfo = $0.split(separator: ":", maxSplits: 2)
      let language = languageInfo[0]
      let dataLine = languageInfo.dropFirst().first
      let highlightColor = languageInfo.dropFirst(2).first
      return (
        class: "language-\(language)\(highlightColor.map { " highlight-\($0)" } ?? "")",
        dataLine: dataLine.map { String($0) }
      )
    }

    // TODO: Style code blocks
    pre {
      let attributes: [HTMLAttribute] = if let language {
        [.class(language.class), language.dataLine.flatMap { .data("line", value: $0) }]
          .compactMap(\.self)
      } else {
        []
      }
      code(attributes: attributes) {
        HTMLText(codeBlock.code)
      }
    }
  }

  @HTMLBuilder
  mutating func visitEmphasis(_ emphasis: Emphasis) -> Result {
    em {
      for child in emphasis.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitHeading(_ heading: Heading) -> Result {
    switch heading.level {
    case 1: h1 {
        for child in heading.children {
          visit(child)
        }
      }
    case 2: h2 {
        for child in heading.children {
          visit(child)
        }
      }
    case 3: h3 {
        for child in heading.children {
          visit(child)
        }
      }
    case 4: h4 {
        for child in heading.children {
          visit(child)
        }
      }
    case 5: h5 {
        for child in heading.children {
          visit(child)
        }
      }
    case 6: h6 {
        for child in heading.children {
          visit(child)
        }
      }
    default: p {
        for child in heading.children {
          visit(child)
        }
      }
    }
  }

  @HTMLBuilder
  mutating func visitHTMLBlock(_ html: HTMLBlock) -> Result {
    HTMLRaw(html.rawHTML)
  }

  @HTMLBuilder
  mutating func visitImage(_ image: Image) -> Result {
    if let source = image.source {
      a(.href(source), .target(.blank), .rel("noopener noreferrer")) {
        img(.src(source))
      }
    }
  }

  @HTMLBuilder
  mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
    code {
      HTMLText(inlineCode.code)
    }
  }

  @HTMLBuilder
  mutating func visitInlineHTML(_ inlineHTML: Markdown.InlineHTML) -> Result {
    HTMLRaw(inlineHTML.rawHTML)
  }

  @HTMLBuilder
  mutating func visitLineBreak(_ lineBreak: Markdown.LineBreak) -> Result {
    br()
  }

  @HTMLBuilder
  mutating func visitLink(_ link: Markdown.Link) -> Result {
    let href = link.destination ?? "/"
    let isLocalLink = href.hasPrefix("/") || href.hasPrefix("#")
    let attributes: [HTMLAttribute] = [
      .href(href),
      link.title.flatMap { .title($0) },
      link.title.flatMap { .aria.label($0) },
      isLocalLink ? nil : .target(.blank),
      isLocalLink ? nil : .rel("noopener noreferrer")
    ]
    .compactMap(\.self)

    a(attributes: attributes) {
      for child in link.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitListItem(_ listItem: Markdown.ListItem) -> Result {
    li {
      for child in listItem.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitOrderedList(_ orderedList: Markdown.OrderedList) -> Result {
    ol {
      for child in orderedList.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitParagraph(_ paragraph: Markdown.Paragraph) -> Result {
    p {
      for child in paragraph.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitSoftBreak(_ softBreak: Markdown.SoftBreak) -> Result {
    softBreak.plainText
  }

  @HTMLBuilder
  mutating func visitStrikethrough(_ strikethrough: Markdown.Strikethrough) -> Result {
    s {
      for child in strikethrough.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitStrong(_ mdStrong: Markdown.Strong) -> Result {
    strong {
      for child in mdStrong.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitTable(_ mdTable: Markdown.Table) -> Result {
    table {
      if !mdTable.head.isEmpty {
        thead {
          tr {
            self.render(
              cells: mdTable.head.cells, 
              columnAlignments: mdTable.columnAlignments
            )
          }
        }
      }
      if !mdTable.body.isEmpty {
        tbody {
          for row in mdTable.body.rows {
            tr {
              self.render(
                cells: row.cells, 
                columnAlignments: mdTable.columnAlignments
              )
            }
          }
        }
      }
    }
  }

  @HTMLBuilder
  private mutating func render(
    cells: some Sequence<Markdown.Table.Cell>,
    columnAlignments: [Markdown.Table.ColumnAlignment?]
  ) -> Result {
    var column = 0
    for cell in cells {
      if cell.colspan > 0, cell.rowspan > 0 {
        td {
          for child in cell.children {
            visit(child)
          }
        }
        // .attribute("align", columnAlignments[column]?.attributeValue)
        .attribute("colspan", value: cell.colspan == 1 ? nil : "\(cell.colspan)")
        .attribute("rowspan", value: cell.rowspan == 1 ? nil : "\(cell.rowspan)")
        let _ = column += Int(cell.colspan)
      }
    }
  }

  @HTMLBuilder
  mutating func visitText(_ text: Markdown.Text) -> Result {
    HTMLText(text.string)
  }

  @HTMLBuilder
  mutating func visitThematicBreak(_ thematicBreak: Markdown.ThematicBreak) -> Result {
    div {
      hr()
    }
  }

  @HTMLBuilder
  mutating func visitUnorderedList(_ unorderedList: Markdown.UnorderedList) -> Result {
    ul {
      for child in unorderedList.children {
        visit(child)
      }
    }
  }
}

extension HTMLBuilder {
  @_disfavoredOverload
  fileprivate static func buildExpression(_ expression: some HTML & Sendable) -> _SendableAnyHTML {
    _SendableAnyHTML(expression)
  }

  @_disfavoredOverload
  fileprivate static func buildFinalResult(_ component: some HTML & Sendable) -> _SendableAnyHTML {
    _SendableAnyHTML(component)
  }
}
