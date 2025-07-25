import Testing
import HTML

@Suite("Tag rendering tests")
struct TagRenderingTests {
  @Test func rendersSingleTag() {
    #expect(p {} == "<p></p>") 
  }
  
  @Test func rendersSingleTagsAsync() async throws {
    try await #expect(div { p {} }.render() == "<div><p></p></div>")
  }

  @Test func rendersSelfClosingTags() {
    #expect(meta() == "<meta>")
  }

  @Test func rendersSelfClosingTagsAsync() async throws {
    try await #expect(meta().render() == "<meta>")
  }

  @Test func rendersMultipleNestedTags() {
    #expect(
      div {
        h1 {}
        div {
          p {}
        }
      } == "<div><h1></h1><div><p></p></div></div>"
    )
  }

  @Test func rendersMultipleNestedTagsAsync() async throws {
    try await #expect(
      div {
        h1 {}
        div {
          p {}
        }
      }.render() == "<div><h1></h1><div><p></p></div></div>"
    )
  }

  @Test func rendersAsyncElement() async throws {
    let html = div {
      let task = Task { 100 }
      
      p { String(await task.value) }
    }

    try await #expect(html.render() == "<div><p>100</p></div>")
  }

  // @Test func rendersNestedTagPretty() {
  //   let html = div {
  //     h1 {}
  //     div {
  //       p {}
  //     }
  //     a {
  //       img()
  //     }
  //   }

  //   withDependencies {
  //     $0.htmlContext = HTMLContext(.pretty)
  //   } operation: {
  //     #expect(
  //       html.render() == """
  //       <div>
  //         <h1></h1>
  //         <div>
  //           <p></p>
  //         </div>
  //         <a>
  //           <img>
  //         </a>
  //       </div>
  //       """
  //     )
  //   }
  // }
}