import Testing
import HTML

@Suite("HTML string tests")
struct StringTests {
  @Test func testName() async throws {
      var interpolation = HTMLString.StringInterpolation(literalCapacity: 1, interpolationCount: 4)
      interpolation.appendLiteral("&Hello<, ")
      interpolation.appendInterpolation("Erik&")
      interpolation.appendLiteral("! ")
      interpolation.appendInterpolation(p {})
      interpolation.appendInterpolation(raw: " li&&eral ")
      interpolation.appendInterpolation(raw: p {})

      let interpolatedString: HTMLString = "&Hello<, Erik&! \(p {}) \(raw: "li&&eral") \(raw: p {})"

      let expectedString = "&amp;Hello&lt;, Erik&amp;! &lt;p>&lt;/p> li&&eral <p></p>"

      #expect(HTMLString(stringInterpolation: interpolation) == expectedString)
      #expect(interpolatedString == expectedString)

      #expect(HTMLRaw("<p></p>") == "<p></p>")      
      #expect(HTMLText("<p></p>") == "&lt;p>&lt;/p>")
  }
}