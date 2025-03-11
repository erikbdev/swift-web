import Testing
import Vue
@testable import VueMacros
import MacroTesting

@Suite("VueScope macro testing")
struct VueScopeTests {
  enum CodeLang: String, Encodable, CaseIterable {
    case swift
    case javascript
    case rust
    case cpp
  }

  private struct RefComponent: HTML {
    let codeLang: Expression

    var body: some HTML {
      button(.v.on(.click, codeLang.assign("HAHAHA"))) {
        "Change Me"
      }
    }
  }

  @Test func vueScopeTest() async throws {
    let scope = #VueScope(CodeLang.swift) { (codeLang: Expression) in }

    #expect(scope.render() == 
      """
      <div v-scope="{ codeLang: "swift" }"></div>
      """
    )
  }
}