import Dependencies
import HTML
import Testing

@Suite("Inline Style Tests")
struct InlineStyleTests {
  @Test func styleClasses() {
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .class
    } operation: {
      @Dependency(\.htmlContext) var context
      return (
        p {}
          .inlineStyle("color", "red")
          .inlineStyle("background", "white")
          .render(),
        context.stylesheet
      )
    }

    #expect(html == #"<p class="color-0 background-1"></p>"#)
    #expect(stylesheet == #".color-0{color:red;}.background-1{background:white;}"#)
  }

  @Test func nestedStyleClasses() {
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .class
    } operation: {
      @Dependency(\.htmlContext) var context
      return (
        p {
          span()
            .inlineStyle("color", "green")
        }
        .inlineStyle("color", "red")
        .inlineStyle("background", "white")
        .render(),
        context.stylesheet
      )
    }

    #expect(html == #"<p class="color-0 background-1"><span class="color-2"></span></p>"#)
    #expect(stylesheet == #".color-0{color:red;}.background-1{background:white;}.color-2{color:green;}"#)
  }

  @Test func sameStyleClasses() {
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .class
    } operation: {
      @Dependency(\.htmlContext) var context
      return (
        p {
          span()
            .inlineStyle("color", "red")
        }
        .inlineStyle("color", "red")
        .inlineStyle("background", "white")
        .render(),
        context.stylesheet
      )
    }

    #expect(html == #"<p class="color-0 background-1"><span class="color-0"></span></p>"#)
    #expect(stylesheet == #".color-0{color:red;}.background-1{background:white;}"#)
  }

  @Test func inlineStyle() {
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = nil
    } operation: {
      @Dependency(\.htmlContext) var context
      return (
        p {}
          .inlineStyle("color", "red")
          .render(),
        context.stylesheet
      )
    }

    #expect(html == #"<p style="color: red;"></p>"#)
    #expect(stylesheet == "")
  }

  @Test func sameStyleGroupedClasses() {
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .groupedStyles
    } operation: {
      @Dependency(\.htmlContext) var context
      return (
        p {
          span()
            .inlineStyle("color", "red")
            .inlineStyle("background", "white")
        }
        .inlineStyle("color", "red")
        .inlineStyle("background", "white")
        .render(),
        context.stylesheet
      )
    }

    #expect(html == #"<p class="c0"><span class="c0"></span></p>"#)
    #expect(stylesheet == #".c0{color:red;background:white;}"#)
  }

  @Test func diffStyleGroupedClasses() {
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .groupedStyles
    } operation: {
      @Dependency(\.htmlContext) var context
      return (
        p {
          span()
            .inlineStyle("color", "green")
            .inlineStyle("background", "white")
        }
        .inlineStyle("color", "red")
        .inlineStyle("background", "white")
        .render(),
        context.stylesheet
      )
    }

    #expect(html == #"<p class="c0"><span class="c1"></span></p>"#)
    #expect(stylesheet == #".c0{color:red;background:white;}.c1{color:green;background:white;}"#)
  }

  @Test func mediaGroupedClass() {
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .groupedStyles
    } operation: {
      @Dependency(\.htmlContext) var context
      return (
        p {}
          .inlineStyle("color", "red")
          .inlineStyle("background", "white")
          .inlineStyle("font-size", "1em", post: "[value]")
          .inlineStyle("background", "green", media: .all)
          .render(),
        context.stylesheet
      )
    }

    #expect(html == #"<p class="c0"></p>"#)
    #expect(stylesheet == #".c0{color:red;background:white;}.c0[value]{font-size:1em;}@media all{.c0{background:green;}}"#)
  }
}
