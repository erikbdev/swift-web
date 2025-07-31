@_spi(Render) import HTML

public enum HydrateContext: Hashable, Sendable {
    case client
    case server
}

public struct HydrateComponent<Content: AsyncHTML>: AsyncHTML {
  let content: @Sendable (HydrateContext) -> Content

  public init(@HTMLBuilder content: @escaping @Sendable (HydrateContext) -> Content) {
    self.content = content
  }

  public init<Awaitable: AsyncHTML>(@HTMLBuilder content: @escaping @Sendable (HydrateContext) async throws -> Awaitable) where Content == AsyncHTMLContent<Awaitable> {
    self.content = { context in
      AsyncHTMLContent {
        try await content(context)
      }
    }
  }

  public var body: HTMLTuple<HTMLAttributes<HTMLElement<Content>>, HTMLAttributes<HTMLElement<Content>>> {
    template {
      content(.client)
    }
    .attribute("v-cloak")
    div {
      content(.server)
    }
    .attribute("v-effect", value: "$el.previousElementSibling.getAttribute(\"v-cloak\") == null && $el.setAttribute(\"hidden\", \"\")")
  }
}

extension HydrateComponent: HTML where Content: HTML {}
extension HydrateComponent: Sendable where Content: Sendable {}
