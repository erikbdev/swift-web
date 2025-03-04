import HTML

public protocol VueComponent: HTML {}

extension VueComponent {
  static var componentName: String { 
    String(
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
  }

  func props() -> ComponentProps {
    // Get refs from rendered body.
    ComponentProps(
      name: Self.componentName,
      refs: [],
      template: body.render()
    )
  }
}

struct ComponentProps {
  let name: String
  let refs: [Reactive]
  let template: String
}

extension VueComponent {
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self, 
    into output: inout Output
  ) {
    tag(Self.componentName) {}.render(into: &output)
  }
}