import HTML
import Testing

@Suite("ForEach rendering tests")
struct ForEachTests {
  @Test func rendersSyncArray() {
    let html = ForEach([0, 1, 2]) { idx in
      p { "\(idx)" }
    }

    #expect(html.render() == "<p>0</p><p>1</p><p>2</p>")
  }

  @Test func rendersAsyncArray() async throws {
    let stream = AsyncStream { c in c.yield(0); c.yield(1); c.yield(2); c.finish() }
    let html = AsyncForEach(stream) { idx in
      p { "\(idx)" }
    }

    try await #expect(html.render() == "<p>0</p><p>1</p><p>2</p>")
  }
}
