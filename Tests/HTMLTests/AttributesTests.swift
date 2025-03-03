import Testing
import HTML

@Suite("Attributes testing")
struct AttributesTests {
  @Test func testSimpleAttribute() async throws {
    let html = p {}
      .attribute("select", value: "true")

    #expect(html.render() == #"<p select="true"></p>"#)
  }

  @Test func testNilAttributeValue() async throws {
    let html = p {}
      .attribute("select", value: nil)
    
    #expect(html.render() == #"<p></p>"#)
  }

  @Test func testAttributeNoValue() async throws {
    let html = p {}
      .attribute("select")
    
    #expect(html.render() == #"<p select></p>"#)
  }

  @Test func testNestedAttribute() async throws {
    let html = p {
      h1 {}
        .attribute("selected", value: "true")
      span {}
    }

    #expect(html.render() == #"<p><h1 selected="true"></h1><span></span></p>"#)
  }

  @Test func appliesSameAttributeToLevelOneHTML() async throws {
    let html = HTMLTuple(
      p {},
      div {},
      span {}
    )
    .attribute("selected", value: "true")

    #expect(html.render() == #"<p selected="true"></p><div selected="true"></div><span selected="true"></span>"#)
  }
}