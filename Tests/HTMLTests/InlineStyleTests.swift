import Testing
import HTML
import Dependencies

@Suite("Inline Style Tests")
struct InlineStyleTests {
  @Test func styleClasses() async throws {
    @Dependency(\.ssg) var ssg
    let (html, stylesheet) = withDependencies {
      $0.ssg = .class
    } operation: {
      (
        p {}
          .inlineStyle("color", "red")
          .inlineStyle("background", "white")
          .render(),
        ssg?.stylesheet()
      )
    }

    #expect(html == #"<p class="color-0 background-1"></p>"#)
    #expect(stylesheet == #".color-0{color:red;}.background-1{background:white;}"#)
  }

  @Test func nestedStyleClasses() async throws {
    @Dependency(\.ssg) var ssg
    let (html, stylesheet) = withDependencies {
      $0.ssg = .class
    } operation: {
     (
        p {
          span()
            .inlineStyle("color", "green")
        }
        .inlineStyle("color", "red")
        .inlineStyle("background", "white")
        .render(),
        ssg?.stylesheet()
      )
    }

    #expect(html == #"<p class="color-0 background-1"><span class="color-2"></span></p>"#)
    #expect(stylesheet == #".color-0{color:red;}.background-1{background:white;}.color-2{color:green;}"#)
  }

  @Test func sameStyleClasses() async throws {
    @Dependency(\.ssg) var ssg
    let (html, stylesheet) = withDependencies {
      $0.ssg = .class
    } operation: {
      (
        p {
          span()
            .inlineStyle("color", "red")
        }
        .inlineStyle("color", "red")
        .inlineStyle("background", "white")
        .render(),
        ssg?.stylesheet()
      )
    }

    #expect(html == #"<p class="color-0 background-1"><span class="color-0"></span></p>"#)
    #expect(stylesheet == #".color-0{color:red;}.background-1{background:white;}"#)
  }

  @Test func inlineStyle() async throws {
    @Dependency(\.ssg) var ssg

    let (html, stylesheet) = withDependencies {
      $0.ssg = nil
    } operation: {
      (
        p {}
          .inlineStyle("color", "red")
          .render(),
        ssg?.stylesheet()
      )
    }

    #expect(html == #"<p style="color: red;"></p>"#)
    #expect(stylesheet == nil)
  }
}