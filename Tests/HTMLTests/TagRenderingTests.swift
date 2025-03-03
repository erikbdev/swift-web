import Testing
import HTML

@Suite("Tag rendering tests")
struct TagRenderingTests {
  @Test func rendersEmptyTag() {
    #expect(p {} == "<p></p>") 
  }

  @Test func rendersNestedTags() {
    #expect(
      div { p {} } == "<div><p></p></div>"
    )
  }

  @Test func rendersSelfClosingTags() {
    #expect(
      meta() == "<meta>"
    )
  }

  @Test func rendersMultipleNestedTags() {
    #expect(
      div {
        h1 {}
        div {
          p {}
        }
      }
      .render() == "<div><h1></h1><div><p></p></div></div>"
    )
  }
}