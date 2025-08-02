import Dependencies
// import DependenciesMacros
import Foundation
@_spi(Render) import HTML

public enum HydrateContext: Hashable, Sendable {
  case hydrated
  case `static`
}

private let randomCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

public struct HydrateComponent<Content: AsyncHTML>: AsyncHTML {
  let content: @Sendable (HydrateContext) -> Content
  let generation: String

  public init(@HTMLBuilder content: @escaping @Sendable (HydrateContext) -> Content) {
    @Dependency(\.base62Generator) var generator
    self.content = content
    self.generation = generator(8)
  }

  public init<Awaitable: AsyncHTML>(@HTMLBuilder content: @escaping @Sendable (HydrateContext) async throws -> Awaitable) where Content == AsyncHTMLContent<Awaitable> {
    self.init { context in
      AsyncHTMLContent {
        try await content(context)
      }
    }
  }

  public var body: HTMLTuple<HTMLAttributes<HTMLElement<Content>>, HTMLAttributes<HTMLElement<Content>>> {
    div {
      content(.static)
    }
    .attribute("v-hydrate-id", value: generation)
    div {
      content(.hydrated)
    }
    .attribute("hidden")
    .attribute("v-effect", value: "document.querySelector('[v-hydrate-id=\"\(generation)\"]').remove(); $el.hidden = false")
  }
}

extension HydrateComponent: HTML where Content: HTML {}
extension HydrateComponent: Sendable where Content: Sendable {}
