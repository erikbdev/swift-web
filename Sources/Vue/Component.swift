import Dependencies
import HTML
import OrderedCollections

/// A VueJS component
public protocol VueComponent: HTML {}

extension VueComponent {
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    @Dependency(\.vueElementContext) var elementContext
    @Dependency(\.vueContext) var context

    let componentName = String(
      String(describing: Self.self)
        .enumerated()
        .flatMap { (idx, c) -> [Character] in
          if !c.isLetter && !c.isNumber {
            return []
          } else if c.isUppercase {
            return (idx > 0 ? ["-" as Character] : []) + c.lowercased()
          } else {
            return [c]
          }
        }
    )

    let component = withDependencies {
      $0.vueElementContext = .liveValue
    } operation: { [html] in
      tag(componentName) {}
        .render(into: &output)
      var template = ""
      html.body.render(into: &template)
      return VueComponentProps(
        name: componentName,
        refs: elementContext.properties(),
        template: template
      )
    }

    context.addComponent(String(describing: Self.self), component)
  }
}

public struct VueComponentProps: Sendable, Hashable {
  public let name: String
  public let refs: OrderedSet<Reactive>
  public let template: String
}

public struct VueElementContext: DependencyKey, Sendable {
  public let addProperty: @Sendable (Reactive) -> Void
  public let properties: @Sendable () -> OrderedSet<Reactive>

  public static var liveValue: VueElementContext {
    let properties = LockIsolated<OrderedSet<Reactive>>([])
    return VueElementContext(
      addProperty: { prop in
        properties.withValue {
          _ = $0.append(prop)
        }
      },
      properties: { properties.value }
    )
  }

  public static var testValue: VueElementContext { .liveValue }
}

extension DependencyValues {
  var vueElementContext: VueElementContext {
    get { self[VueElementContext.self] }
    set { self[VueElementContext.self] = newValue }
  }
}

public struct VueContext: DependencyKey, Sendable {
  let addComponent: @Sendable (_ name: String, VueComponentProps) -> Void
  public let allComponents: @Sendable () -> OrderedDictionary<String, VueComponentProps>

  public static var liveValue: VueContext {
    let components = LockIsolated<OrderedDictionary<String, VueComponentProps>>([:])
    return VueContext(
      addComponent: { name, element in
        components.withValue {
          $0[name] = element
        }
      },
      allComponents: { components.value }
    )
  }

  static var testValue: VueElementContext { .liveValue }
}

extension DependencyValues {
  public var vueContext: VueContext {
    get { self[VueContext.self] }
    set { self[VueContext.self] = newValue }
  }
}
