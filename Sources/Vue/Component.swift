import Elementary

public protocol VueComponent: HTML {
  associatedtype Body: HTML
  @HTMLBuilder var body: Body { get }
}

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
      template: body.renderFormatted()
    )
  }
}

struct ComponentProps {
  let name: String
  let refs: [Reactive]
  let template: String
}

extension VueComponent {
  public static func _render<Renderer: _AsyncHTMLRendering>(
    _ html: consuming Self, 
    into renderer: inout Renderer, 
    with context: consuming _RenderingContext
  ) async throws {
    try await renderer.appendToken(.raw("<\(Self.componentName)></\(Self.componentName)>"))
  }

  public static func _render<Renderer: _HTMLRendering>(
    _ html: consuming Self, 
    into renderer: inout Renderer, 
    with context: consuming _RenderingContext
  ) {
    renderer.appendToken(.raw("<\(Self.componentName)></\(Self.componentName)>"))
  }
}