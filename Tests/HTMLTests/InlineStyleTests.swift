import Testing
import HTML
import Dependencies

@Suite("Inline Style Tests")
struct InlineStyleTests {
  @Test func styleClasses() async throws {
    let html = withDependencies {
      $0.styleSheetGenerator = .class
    } operation: {
      p {}
      .inlineStyle("color", "red")
      .inlineStyle("background", "white")
      .render()
    }

    #expect(html == #"<p class="color-0 background-1"></p>"#)
  }

  @Test func nestedStyleClasses() async throws {
    let html = withDependencies {
      $0.styleSheetGenerator = .class
    } operation: {
      p {
        span()
          .inlineStyle("color", "green")
      }
      .inlineStyle("color", "red")
      .inlineStyle("background", "white")
      .render()
    }

    #expect(html == #"<p class="color-0 background-1"><span class="color-2"></span></p>"#)
  }

  @Test func sameStyleClasses() async throws {
    let html = withDependencies {
      $0.styleSheetGenerator = .class
    } operation: {
      p {
        span()
          .inlineStyle("color", "red")
      }
      .inlineStyle("color", "red")
      .inlineStyle("background", "white")
      .render()
    }

    #expect(html == #"<p class="color-0 background-1"><span class="color-0"></span></p>"#)
  }


  @Test func stylesheetGenerator() async throws {
    let html = withDependencies {
      $0.styleSheetGenerator = nil
    } operation: {
       p {}
        .inlineStyle("color", "red")
        .render()
    }

    #expect(html == #"<p style="color: red;"></p>"#)
  }
}