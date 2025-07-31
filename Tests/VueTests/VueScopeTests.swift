import MacroTesting
import Testing

@testable import Vue
@testable import VueMacros

@Suite("VueScope macro testing")
struct VueScopeTests {
  enum CodeLang: String, Encodable, CaseIterable {
    case swift
    case javascript
    case rust
    case cpp
  }

  @Vue.Component
  struct ButtonLanguage: HTML {
    @Vue.Reactive let codeLang = CodeLang.swift

    var name = "john"

    var body: some HTML {
      button(.v.on(.click, $codeLang.assign(.rust))) {
        "Language \($codeLang)"
      }
    }
  }

  @Vue.Component
  struct ButtonLanguageWithHydration: HTML {
    @Vue.Reactive let codeLang = CodeLang.swift

    var name = "john"

    var body: some HTML {
      button(.v.on(.click, $codeLang.assign(.rust))) {
        "Language \($codeLang)"
      }
    }
  }

  @Test func vueScopeTest() {
    let scope = #VueScope(CodeLang.swift) { codeLang in
      button(.v.on(.click, codeLang.assign(.rust))) {
        "Language \(codeLang)"
      }
    }

    #expect(
      scope.render() == """
        <div v-scope="{&quot;codeLang&quot;:&quot;swift&quot;}"><button v-on:click="codeLang = &quot;rust&quot;">Language {{ codeLang }}</button></div>
        """
    )
  }

  @Test func vueScopeTestWithHydration() {
    let scope = #VueScope(CodeLang.swift) { codeLang in
      button(.v.on(.click, codeLang.assign(.rust))) {
        HydrateComponent { context in
          switch context {
            case .client: 
              "Language \(codeLang)"
            case .server: 
              "Language \(codeLang.initialValue.rawValue)"
          }
        }
      }
    }

    #expect(
      scope.render() == """
        <div v-scope="{&quot;codeLang&quot;:&quot;swift&quot;}"><button v-on:click="codeLang = &quot;rust&quot;">Language {{ codeLang }}</button></div>
        """
    )
  }

  @Test func vueComponentPropsTest() {
    let html = ButtonLanguage()

    #expect(html.allProps.initialValue.count == 1)
    #expect(html.allProps.initialValue["codeLang"] != nil)
    #expect((html.allProps.initialValue["codeLang"]?.base as? CodeLang) == CodeLang.swift)
  }

  @Test func vueComponentRenderTest() {
    let html = ButtonLanguage()

    #expect(
      html.render() == """
        <div v-scope="{&quot;codeLang&quot;:&quot;swift&quot;}"><button v-on:click="codeLang = &quot;rust&quot;">Language {{ codeLang }}</button></div>
        """
    )
  }
}
