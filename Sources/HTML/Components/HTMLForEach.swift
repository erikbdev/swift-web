public struct ForEach<S, Element, Content: AsyncHTML>: AsyncHTML {
  let sequence: S
  let content: @Sendable (Element) -> Content

  public var body: Never { fatalError() }

  public init(
    _ sequence: S,
    @HTMLBuilder content: @escaping @Sendable (S.Element) -> Content
  ) where S: Sequence, S.Element == Element {
    self.sequence = sequence
    self.content = content
  }

  public init<Awaitable: AsyncHTML>(
    _ sequence: S,
    @HTMLBuilder content: @escaping @Sendable (S.Element) async throws -> Awaitable
  ) where S: Sequence, S.Element == Element, Element: Sendable, Content == AsyncHTMLContent<Awaitable> {
    self.init(sequence) { item in
      AsyncHTMLContent { try await content(item) }
    }
  }

  public init(
    _ sequence: S,
    @HTMLBuilder content: @escaping @Sendable (S.Element) -> Content
  ) where S: AsyncSequence, S.Element == Element {
    self.sequence = sequence
    self.content = content
  }

  public init<Awaitable: AsyncHTML>(
    _ sequence: S,
    @HTMLBuilder content: @escaping @Sendable (S.Element) async throws -> Awaitable
  ) where S: AsyncSequence, S.Element == Element, Element: Sendable, Content == AsyncHTMLContent<Awaitable> {
    self.init(sequence) { item in
      AsyncHTMLContent { try await content(item) }
    }
  }

  @_spi(Render)
  public static func _render<Output: AsyncHTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    if let sequence = html.sequence as? any Sequence<Element> {
      for element in sequence {
        try await Content._render(html.content(element), into: &output)
      }
    } else if let sequence = html.sequence as? any AsyncSequence {
      for try await element in sequence {
        let unsafeElement = unsafeBitCast(element, to: Element.self)
        try await Content._render(html.content(unsafeElement), into: &output)
      }
    } else {
      fatalError("Expected a sequence that implements Sequence<\(Element.self)> or AsyncSequence<\(Element.self)> but instead received \(S.self).")
    }
  }
}

extension ForEach: HTML where S: Sequence, S.Element == Element, Content: HTML {
  @_spi(Render)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    for element in html.sequence {
      Content._render(html.content(element), into: &output)
    }
  }
}

extension ForEach: Sendable where S: Sendable, Element: Sendable, Content: Sendable {}