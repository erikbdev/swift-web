import MacroTesting
import Testing
import Vue

@testable import VueMacros

@Suite("VueScope macro testing")
struct VueScopeTests {
  enum CodeLang: String, Encodable, CaseIterable {
    case swift
    case javascript
    case rust
    case cpp
  }

  @Test func vueScopeTest() async throws {
    let scope = #VueScope(CodeLang.swift) { codeLang in
      button(.v.on(.click, codeLang.assign("HAHAHA"))) {
        "Change Me"
      }
    }

    #expect(
      scope.render() == """
        <div v-scope="{&quot;codeLang&quot;:&quot;swift&quot;}"><button v-on:click="codeLang = &quot;HAHAHA&quot;">Change Me</button></div>
        """
    )
  }
}
