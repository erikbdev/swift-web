import HTML
import Testing

@Suite("Attributes testing")
struct AttributesTests {
  @Test func testSimpleAttribute() {
    let html = p {}
      .attribute("select", value: "true")
      .render()

    #expect(html == #"<p select="true"></p>"#)
  }

  @Test func testNilAttributeValue() {
    let html = p {}
      .attribute("select", value: nil)

    #expect(html.render() == #"<p></p>"#)
  }

  @Test func testAttributeNoValue() {
    let html = p {}
      .attribute("select")

    #expect(html.render() == #"<p select></p>"#)
  }

  @Test func testNestedAttribute() {
    let html = p {
      h1 {}
        .attribute("selected", value: "true")
      span {}
    }

    #expect(html.render() == #"<p><h1 selected="true"></h1><span></span></p>"#)
  }

  @Test func appliesSameAttributeToLevelOneHTML() {
    let html = HTMLTuple(
      p {},
      div {},
      span {}
    )
    .attribute("selected")

    #expect(html.render() == #"<p selected></p><div selected></div><span selected></span>"#)
  }

  @Test func replaceAttributeValue() {
    let html = p {}
      .attribute("selected", value: "true")
      .attribute("selected")

    #expect(html.render() == #"<p selected></p>"#)
  }

  @Test func mergeAttributeValues() {
    let html = p {}
      .attribute("class", value: "test-0")
      .attribute("class", value: "test-1", mergeMode: .mergeValue)

    #expect(html.render() == #"<p class="test-0 test-1"></p>"#)
  }

  @Test func ignoreIfSet() {
    let html = p {}
      .attribute("class", value: "test-0")
      .attribute("class", value: "test-1", mergeMode: .ignoreIfSet)

    #expect(html.render() == #"<p class="test-0"></p>"#)
  }

  @Test func attributeOrder() {
    let html = p {}
      .attribute("data-test", value: "{}")
      .attribute("class", value: "red-0")
      .attribute("selected")

    #expect(html.render() == #"<p class="red-0" selected data-test="{}"></p>"#)
  }
}
