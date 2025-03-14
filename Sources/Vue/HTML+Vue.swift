import Dependencies
import HTML

public struct VueScript: HTML {
  public var body: some HTML {
    script(.type(.module), .defer) {
      """
      import { createApp } from "https://unpkg.com/petite-vue@0.4.1/dist/petite-vue.es.js";
      createApp().mount();
      """
    }
  }
}

extension HTMLAttribute {
  /// A namespace for VueJS attributes.
  /// See the [VueJS directives](https://vuejs.org/api/built-in-directives) for more information.
  public struct Vue {}

  public static var v: Vue { Vue() }
}

extension HTMLAttribute.Vue {
  public struct OnEventModifier: Sendable, Hashable {
    fileprivate let chain: [String]

    private init(_ modifier: String = #function) {
      self.chain = [modifier]
    }

    private init(_ chain: [String]) {
      self.chain = chain
    }

    public var stop: Self { add() }
    public var prevent: Self { add() }
    public var capture: Self { add() }
    public var `self`: Self { add() }
    public func key(_ alias: String) -> Self { add(alias) }
    public var once: Self { add() }
    public var left: Self { add() }
    public var right: Self { add() }
    public var middle: Self { add() }
    public var passive: Self { add() }

    public static var stop: Self { Self() }
    public static var prevent: Self { Self() }
    public static var capture: Self { Self() }
    public static var `self`: Self { Self() }
    public static func key(_ alias: String) -> Self { Self(alias) }
    public static var once: Self { Self() }
    public static var left: Self { Self() }
    public static var right: Self { Self() }
    public static var middle: Self { Self() }
    public static var passive: Self { Self() }

    private func add(_ modifier: String = #function) -> Self {
      Self(chain + [modifier])
    }
  }

  public struct ModelModifier: Sendable, Hashable {
    fileprivate let chain: [String]

    private init(_ modifier: String = #function) {
      self.chain = [modifier]
    }

    private init(_ chain: [String]) {
      self.chain = chain
    }

    public var `lazy`: Self { add() }
    public var number: Self { add() }
    public var trim: Self { add() }

    public static var `lazy`: Self { Self() }
    public static var number: Self { Self() }
    public static var trim: Self { Self() }

    private func add(_ modifier: String = #function) -> Self {
      Self(chain + [modifier])
    }
  }

  /// Update the element's text content.
  public func text<T>(_ script: Expression<T>) -> HTMLAttribute {
    directive(name: "text", script.rawValue)
  }

  /// Update the element's innerHTML.
  public func html<T>(_ script: Expression<T>) -> HTMLAttribute {
    directive(name: "html", script.rawValue)
  }

  /// Toggle the element's visibility based on the truthy-ness of the expression value.
  public func show<T>(_ script: Expression<T>) -> HTMLAttribute {
    directive(name: "show", script.rawValue)
  }

  /// Conditionally render an element or a template fragment based on the truthy-ness of the expression value.
  public func `if`<T>(_ script: Expression<T>) -> HTMLAttribute {
    directive(name: "if", script.rawValue)
  }

  /// Denote the "else block" for ``v-if`` or a ``v-if`` / ``v-else-if`` chain.
  public var `else`: HTMLAttribute {
    directive(name: "else")
  }

  /// Denote the "else if block" for ``v-if``. Can be chained.
  public func elseIf<T>(_ script: Expression<T>) -> HTMLAttribute {
    directive(name: "else-if", script.rawValue)
  }

  /// Render the element or template block multiple times based on the source data.
  public func `for`<T>(_ script: Expression<T>) -> HTMLAttribute {
    directive(name: "else-if", script.rawValue)
  }

  /// Attach an event listener to the element.
  public func on<Event: HTMLEventValue, T>(
    _ event: Event,
    modifiers: OnEventModifier? = nil,
    _ script: Expression<T>
  ) -> HTMLAttribute {
    directive(
      name: "on",
      argument: event.rawValue,
      modifiers: modifiers.flatMap { $0.chain } ?? [],
      script.rawValue
    )
  }

  /// Dynamically bind one or more attributes, or a component prop to an expression.
  public func bind<T>(
    attrOrProp: String,
    _ script: Expression<T>
  ) -> HTMLAttribute {
    directive(
      name: "bind",
      argument: attrOrProp,
      script.rawValue
    )
  }

  public func bind<T>(_ script: Expression<T>) -> HTMLAttribute {
    directive(name: "bind", script.rawValue)
  }

  /// Create a two-way binding on a form input element or a component.
  public func model<T>(
    modifiers: ModelModifier? = nil,
    _ script: Expression<T>
  ) -> HTMLAttribute {
    directive(
      name: "model",
      modifiers: modifiers?.chain ?? [],
      script.rawValue
    )
  }

  /// Denote named slots or scoped slots that expect to receive props.
  public func slot<T>(
    name: String? = nil,
    _ script: Expression<T>? = ""
  ) -> HTMLAttribute {
    directive(
      name: "slot",
      argument: name ?? "",
      script?.rawValue
    )
  }

  /// Skip compilation for this element and all its children.
  public var pre: HTMLAttribute {
    directive(name: "pre")
  }

  /// Render the element and component once only, and skip future updates.
  public var once: HTMLAttribute {
    directive(name: "once")
  }

  /// Used to hide un-compiled template until it is ready.
  public var cloak: HTMLAttribute {
    directive(name: "cloak")
  }

  /// Used as a replacement for `#app`, works the same way as `v-scope` in `petite-vue`
  public func scope<T>(_ expression: Expression<T>) -> HTMLAttribute {
    directive(
      name: "scope",
      expression.rawValue
    )
  }

  private func directive(
    name: String,
    argument: String = "",
    modifiers: [String] = [],
    _ value: String? = ""
  ) -> HTMLAttribute {
    HTMLAttribute(
      name: "v-\(name)\(argument.isEmpty ? "" : ":\(argument)")\(modifiers.isEmpty ? "" : ".\(modifiers.joined(separator: "."))")",
      value: value
    )
  }
}