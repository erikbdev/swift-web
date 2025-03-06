import Dependencies
import Foundation
import HTML

public struct VueScript: HTML {
  let config: Configuration

  @Dependency(\.vueContext) var vueContext

  public enum Configuration: String {
    case development = ""
    case production = "prod"
  }

  public init() {
    #if DEBUG
      self.config = .development
    #else
      self.config = .production
    #endif
  }

  public init(_ configuration: Configuration) {
    self.config = configuration
  }

  public var body: some HTML {
    script(.type(.module), .defer) {
      let components = vueContext.allComponents()

      let componentVariables = components.map {
        """
        const \($0.key) = {
          setup() {
            \($0.value.refs.map(\.initializer).joined(separator: "\n"))
            return {\($0.value.refs.map(\.name).joined(separator: ", "))}
          },
          template: `\($0.value.template)`
        };
        """
      }

      HTMLRaw(
        """
        import { createApp, reactive, ref } from 'https://unpkg.com/vue@3/dist/vue.esm-browser\(config.rawValue).js';

        \(componentVariables.joined(separator: "\n"))

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
          \(
            components.map { 
              """
              .component("\($0.value.name)", \($0.key))
              """
            }
            .joined(separator: "\n")
           )
          .mount(root)
        }
        """
      )
    }
  }
}

public struct VueDocument<Head: HTML, Body: HTML>: HTMLDocument {
  public var head: Head
  public var body: Body

  public init(
    @HTMLBuilder head: () -> Head,
    @HTMLBuilder body: () -> Body
  ) {
    self.head = head()
    self.body = body()
  }

  public static func _render<Output: HTMLByteStream>(
    _ document: Self,
    into output: inout Output
  ) {
    withDependencies {
      $0.vueContext = .liveValue
    } operation: {
      BaseDocument._render(
        BaseDocument(
          head: document.head,
          body: HTMLGroup {
            document.body
            VueScript()
          }
        ),
        into: &output
      )
    }
  }
}

private struct BaseDocument<Head: HTML, Body: HTML>: HTMLDocument {
  var head: Head
  var body: Body
}

extension VueDocument: Sendable where Head: Sendable, Body: Sendable {}

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
  public func text<E: ExpressionRepresentable>(_ script: E) -> HTMLAttribute {
    directive(name: "text", script.expression)
  }

  /// Update the element's innerHTML.
  public func html<E: ExpressionRepresentable>(_ script: E) -> HTMLAttribute {
    directive(name: "html", script.expression)
  }

  /// Toggle the element's visibility based on the truthy-ness of the expression value.
  public func show<E: ExpressionRepresentable>(_ script: E) -> HTMLAttribute {
    directive(name: "show", script.expression)
  }

  /// Conditionally render an element or a template fragment based on the truthy-ness of the expression value.
  public func `if`<E: ExpressionRepresentable>(_ script: E) -> HTMLAttribute {
    directive(name: "if", script.expression)
  }

  /// Denote the "else block" for ``v-if`` or a ``v-if`` / ``v-else-if`` chain.
  public var `else`: HTMLAttribute {
    directive(name: "else")
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
  public func on<Event: HTMLEventValue>(
    _ event: Event,
    modifiers: OnEventModifier? = nil,
    _ script: Expression
  ) -> HTMLAttribute {
    directive(
      name: "on",
      argument: event.rawValue,
      modifiers: modifiers.flatMap { $0.chain } ?? [],
      script.expression
    )
  }

  /// Dynamically bind one or more attributes, or a component prop to an expression.
  public func bind<E: ExpressionRepresentable>(
    attrOrProp: String,
    _ script: E
  ) -> HTMLAttribute {
    directive(
      name: "bind",
      argument: attrOrProp,
      script.expression
    )
  }

  public func bind<E: ExpressionRepresentable>(_ script: E) -> HTMLAttribute {
    directive(name: "bind", script.expression)
  }

  /// Create a two-way binding on a form input element or a component.
  public func model<E: ExpressionRepresentable>(
    modifiers: ModelModifier? = nil,
    _ script: E
  ) -> HTMLAttribute {
    directive(
      name: "model",
      modifiers: modifiers?.chain ?? [],
      script.expression
    )
  }

  /// Denote named slots or scoped slots that expect to receive props.
  public func slot<E: ExpressionRepresentable>(
    name: String? = nil,
    _ script: E? = nil
  ) -> HTMLAttribute {
    directive(
      name: "slot",
      argument: name ?? "",
      script?.expression
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
  public func scope(_ script: Expression) -> HTMLAttribute {
    directive(
      name: "scope",
      script.expression
    )
  }

  private func directive(
    name: String,
    argument: String = "",
    modifiers: [String] = [],
    _ value: String? = nil
  ) -> HTMLAttribute {
    HTMLAttribute(
      name: "v-\(name)\(argument.isEmpty ? "" : ":\(argument)")\(modifiers.isEmpty ? "" : ".\(modifiers.joined(separator: "."))")",
      value: value
    )
  }
}
