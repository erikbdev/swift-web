import Dependencies
import MacroTesting
import Testing
import Vue
import VueMacros

@Test func testCreateJSVariable() async throws {
  let test1 = Reactive(name: "test1", value: "hello")
  let test2 = Reactive(name: "test2", value: 0)
  let test3 = Reactive(name: "test3", value: [:])
  let test4 = Reactive(name: "test4", value: nil)
  let test5 = Reactive(name: "test5", value: [])

  #expect(
    """
    const test1 = ref("hello");
    """ == test1.initializer,
    "Failed to validate mutable variable"
  )

  #expect(
    """
    const test2 = ref(0);
    """ == test2.initializer,
    "Failed to validate mutable variable"
  )

  #expect(
    """
    const test3 = ref({});
    """ == test3.initializer,
    "failed to validate constant variable"
  )

  #expect(
    """
    const test4 = ref(null);
    """ == test4.initializer,
    "failed to validate constant variable"
  )

  #expect(
    """
    const test5 = ref([]);
    """ == test5.initializer,
    "failed to validate constant variable"
  )

  #expect(
    """
    test2 * test3
    """ == test2 * test3
  )

  #expect(
    """
    test2 * 0
    """ == test2 * 0
  )

  #expect(
    """
    test1 + 0
    """ == test1 + 0
  )

  #expect(
    """
    !test1
    """ == !test1
  )
}

@Test func reactiveMacrosTests() async throws {
  assertMacro(
    ["Reactive": ReactiveMacro.self],
    record: .all
  ) {
    """
    struct TestComponent {
      @Reactive let count: Int
      @Reactive let message = "yes"
    }
    """
  }
}

struct CustomComponent: VueComponent {
  @Reactive let name = "World"
  @Reactive let isShowing = false

  var body: some HTML {
    p { "Hello, \($name)!" }
    button(.v.on(.click, Expression(rawValue: "\($name.name) = \"Erik\";"))) {
      "Change name"
    }
    div(.v.show($isShowing)) {
      "Showing div!"
    }
  }
}

@Test func reactiveComponent() async throws {
  let component = CustomComponent()

  withDependencies {
    $0.vueContext = .liveValue
  } operation: {
    @Dependency(\.vueContext) var context

    let rendered = component.render()

    #expect(rendered == "<custom-component></custom-component>")

    guard let component = context.allComponents().elements.first else {
      fatalError("No component was rendered")
    }

    #expect(component.0 == "CustomComponent")
    #expect(component.1.name == "custom-component")
    #expect(
      component.1.template
        == #"<p>Hello, {{ name }}!</p><button v-on:click="name = &quot;Erik&quot;;">Change name</button><div v-show="isShowing">Showing div!</div>"#
    )
    #expect(component.1.refs.count == 2)
  }
}

@Test func vueDocumentTest() {
  let html = VueDocument {

  } body: {
    CustomComponent()
  }

  #expect(
    html.render() == """
    <!doctype html>
    <head></head>
    <body><custom-component></custom-component><script></script></body>
    """
  )
}
