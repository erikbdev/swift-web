import Foundation
import HTML

struct VueScript: HTML {
  #if DEBUG
    private static let config = ""
  #else
    private static let config = ".prod"
  #endif

  var body: some HTML {
    script(.type(.importmap)) {
      """
      {
        "imports": {
          "vue": "https://unpkg.com/vue@3/dist/vue.esm-browser\(Self.config).js"
        }
      }
      """
    }
    script(.type(.module), .defer) {
      HTMLRaw(
        """
        import { createApp, reactive } from 'vue';

        const roots = [...document.documentElement.querySelectorAll(`[v-scope]`)]
          .filter((root) => !root.matches(`[v-scope] [v-scope]`));

        // Similar to how `v-scope` works in `petite-vue`
        for (const root of roots) {
          const expr = root.getAttribute('v-scope');
          root.removeAttribute('v-scope');
          if (!expr) continue;
          createApp({
            setup: reactive.bind(null, new Function(`return(${expr})`)())
          })
          .mount(root)
        }
        """
      )
    }
  }
}

// struct VueOperation: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
//   let rawValue: String

//   init() {
//     rawValue = ""
//   }

//   init(stringLiteral value: String) {
//     rawValue = value
//   }

//   func assign(_ value: VueOperation) -> VueOperation {
//     VueOperation()
//   }

//   func assign<S>(_ value: VueState<S>) -> VueOperation {
//     VueOperation()
//   }

//   static prefix func ! (_ self: Self) -> VueOperation {
//     VueOperation()
//   }
// }

// protocol VueComponent: HTML where Content == Never {
//   associatedtype Body: HTML

//   var body: Body { get }
// }

extension HTMLAttribute {
  /// A namespace for VueJS attributes.
  /// See the [VueJS directives](https://vuejs.org/api/built-in-directives) for more information.
  public struct Vue {}

  public static var v: Vue { Vue() }
}

extension HTMLAttribute.Vue {
  public struct OnEventModifier {
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

  /// Update the element's text content.
  public func text<E: ExpressionRepresentable>(_ script: E) -> HTMLAttribute {
    directive(script.expression)
  }

  /// Update the element's innerHTML.
  public func html<E: ExpressionRepresentable>(_ script: E) -> HTMLAttribute {
    directive(script.expression)
  }

  /// Toggle the element's visibility based on the truthy-ness of the expression value.
  public func show<E: ExpressionRepresentable>(_ script: E) -> HTMLAttribute {
    directive(script.expression)
  }

  /// Conditionally render an element or a template fragment based on the truthy-ness of the expression value.
  public func `if`<E: ExpressionRepresentable>(_ script: E) -> HTMLAttribute {
    directive(script.expression)
  }

  /// Denote the "else block" for ``v-if`` or a ``v-if`` / ``v-else-if`` chain.
  public var `else`: HTMLAttribute {
    directive()
  }

  /// Denote the "else if block" for ``v-if``. Can be chained.
  public func elseIf<E: ExpressionRepresentable>(_ script: E) -> HTMLAttribute {
    directive(name: "else-if", script.expression)
  }

  /// Render the element or template block multiple times based on the source data.
  public func `for`<E: ExpressionRepresentable>(_ script: E) -> HTMLAttribute {
    directive(name: "else-if", script.expression)
  }

  /// Attach an event listener to the element.
  public func on<S: StatementRepresentable, Event: HTMLEventValue>(
    _ event: Event,
    modifiers: OnEventModifier? = nil,
    _ script: S
  ) -> HTMLAttribute {
    directive(name: "on:\(event.rawValue)\(modifiers.flatMap { ".\($0.chain.joined(separator: "."))" } ?? "")", script.statement)
  }

  /// Dynamically bind one or more attributes, or a component prop to an expression.
  public func bind<E: ExpressionRepresentable>(
    _ attrOrProp: String,
    _ script: E
  ) -> HTMLAttribute {
    directive(name: "bind:\(attrOrProp)", script.expression)
  }

  public func bind<E: ExpressionRepresentable>(
    _ script: E
  ) -> HTMLAttribute {
    directive(script.expression)
  }

  /// Create a two-way binding on a form input element or a component.
  public func model<E: ExpressionRepresentable>(
    _ attribute: String? = nil,
    _ modifiers: String? = nil,
    _ script: E
  ) -> HTMLAttribute {
    directive(script.expression)
  }

  /// Denote named slots or scoped slots that expect to receive props.
  public func slot<E: ExpressionRepresentable>(name: String? = nil, _ script: E? = nil) -> HTMLAttribute {
    directive(name: "slot\(name.flatMap { ":\($0)" } ?? "" )", script?.expression)
  }

  /// Skip compilation for this element and all its children.
  public var pre: HTMLAttribute {
    directive()
  }

  /// Render the element and component once only, and skip future updates.
  public var once: HTMLAttribute {
    directive()
  }

  /// Used to hide un-compiled template until it is ready.
  public var cloak: HTMLAttribute {
    directive()
  }

  /// Used as a replacement for `#app`, works the same way as `v-scope` in `petite-vue`
  public func scope(_ script: Expression) -> HTMLAttribute {
    directive(script.expression)
  }

  private func directive(
    name: String = #function,
    _ script: String? = nil
  ) -> HTMLAttribute {
    .init(name: "v-\(name.components(separatedBy: "(").first ?? name)", value: script)
  }
}
