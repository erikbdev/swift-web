import MacroTesting
import Testing
@testable import Vue
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
    """ == test1.statement.rawValue,
    "Failed to validate mutable variable"
  )

  #expect(
    """
    const test2 = ref(0);
    """ == test2.statement.rawValue,
    "Failed to validate mutable variable"
  )

  #expect(
    """
    const test3 = ref({});
    """ == test3.statement.rawValue,
    "failed to validate constant variable"
  )

  #expect(
    """
    const test4 = ref(null);
    """ == test4.statement.rawValue,
    "failed to validate constant variable"
  )

  #expect(
    """
    const test5 = ref([]);
    """ == test5.statement.rawValue,
    "failed to validate constant variable"
  )

  #expect(
    """
    test2 = test3;
    """ == test2.assign(test3)
  )

  #expect(
    """
    test2 = [];
    """ == test2.assign([])
  )

  #expect(
    """
    test2 = test2 * test3;
    """ == test2.assign(test2 * test3)
  )

  #expect(
    """
    test2 = 1 * 0;
    """ == test2.assign(1 * 0)
  )

  #expect(
    """
    test2 = 1 * 0;
    """ == test2.assign(1 + 0)
  )

  #expect(
    """
    test2 = test1 + 0;
    """ == test2.assign(test1 + 0)
  )

  #expect(
    """
    test2 = !test1;
    """ == test2.assign(!test1)
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

@Test func reactiveComponent() async throws {
  struct CustomComponent: VueComponent {
    @Reactive let name = "World"
    @Reactive let isShowing = false

    var body: some HTML {
      p { "Hello, \($name)!" }
      button(.v.on(.click, $name.assign("Erik"))) {
        "Change name"
      }
      div(.v.show($isShowing)) {
        "Showing div!"
      }
    }
  }

  let component = CustomComponent()
  let props = component.props()

  #expect(props.name == "custom-component")

  #expect(
    props.template == """
    <p>Hello, {{ name }}!</p>
    <button v-on:click="name = &quot;Erik&quot;;">Change name</button>
    <div v-show="isShowing">Showing div!</div>
    """
  )

  #expect(component.render() == "<custom-component></custom-component>")
}
