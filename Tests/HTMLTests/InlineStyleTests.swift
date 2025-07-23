import Testing
import HTML
import Dependencies

@Suite("Inline Style Tests")
struct InlineStyleTests {
  @Test func styleClasses() async throws {
    @Dependency(\.htmlContext) var context
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .class
    } operation: {
      (
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

  @Test func nestedStyleClasses() async throws {
    @Dependency(\.htmlContext) var context
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .class
    } operation: {
     (
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

  @Test func sameStyleClasses() async throws {
    @Dependency(\.htmlContext) var context
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .class
    } operation: {
      (
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

  @Test func inlineStyle() async throws {
    @Dependency(\.htmlContext) var context
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = nil
    } operation: {
      (
        p {}
          .inlineStyle("color", "red")
          .render(),
        context.stylesheet
      )
    }

    #expect(html == #"<p style="color: red;"></p>"#)
    #expect(stylesheet == "")
  }

  @Test func sameStyleGroupedClasses() async throws {
    @Dependency(\.htmlContext) var context
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .groupedStyles
    } operation: {
      (
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

  @Test func diffStyleGroupedClasses() async throws {
    @Dependency(\.htmlContext) var context
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .groupedStyles
    } operation: {
      (
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

  @Test func mediaGroupedClass() async throws {
    @Dependency(\.htmlContext) var context
    let (html, stylesheet) = withDependencies {
      $0.htmlContext.styles = .groupedStyles
    } operation: {
      (
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