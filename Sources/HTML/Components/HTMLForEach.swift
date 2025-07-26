public struct ForEach<S: Sequence, Content: HTML>: HTML {
  let sequence: S
  let content: @Sendable (S.Element) -> Content

  public var body: Never { fatalError() }

  public init(_ sequence: S, @HTMLBuilder content: @escaping @Sendable (S.Element) -> Content) {
    self.sequence = sequence
    self.content = content
  }

  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    for element in html.sequence {
      Content._render(html.content(element), into: &output)
    }
  }

  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    for element in html.sequence {
      try await Content._render(html.content(element), into: &output)
    }
  }
}

extension ForEach: Sendable where S: Sendable, Content: Sendable {}

public struct AsyncForEach<S: AsyncSequence, Content: AsyncHTML>: AsyncHTML {
  let sequence: S
  let content: @Sendable (S.Element) -> Content

  public var body: Never { fatalError() }

  public init(_ sequence: S, @HTMLBuilder content: @escaping @Sendable (S.Element) -> Content) {
    self.sequence = sequence
    self.content = content
  }

  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    for try await element in html.sequence {
      try await Content._render(html.content(element), into: &output)
    }
  }
}

extension AsyncForEach: Sendable where S: Sendable, Content: Sendable {}

@available(*, unavailable, message: "'AsyncForEach' does not support synchronous context")
extension AsyncForEach: HTML where Content: HTML {}