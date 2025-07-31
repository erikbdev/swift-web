@_spi(Render) import HTML

public protocol Component: AsyncHTML {
  var allProps: Expression<[String: AnyEncodable]> { get }
}

extension Component {
  public static func _render<Output: AsyncHTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    if html.allProps.initialValue.isEmpty {
      try await Body._render(html.body, into: &output)
    } else {
      try await HTMLAttributes<HTMLElement<Body>>._render(
        HTMLAttributes(
          attributes: [.v.scope(html.allProps)], 
          content: div { html.body }
        ),
        into: &output
      )
    }
  }
}

extension Component where Self: HTML {
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    if html.allProps.initialValue.isEmpty {
      Body._render(html.body, into: &output)
    } else {
      HTMLAttributes<HTMLElement<Body>>._render(
        HTMLAttributes(
          attributes: [.v.scope(html.allProps)], 
          content: div { html.body }
        ),
        into: &output
      )
    }
  }
}
