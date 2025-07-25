public struct AsyncHTMLContent<Content: AsyncHTML>: AsyncHTML, Sendable {
  @usableFromInline
  let content: @Sendable () async throws -> Content

  @inlinable @inline(__always)
  public var body: Never { fatalError() }

  @inlinable @inline(__always)
  public init(@HTMLBuilder content: @escaping @Sendable () async throws -> Content) {
    self.content = content
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    try await Content._render(html.content(), into: &output)
  }
}

@available(*, unavailable, message: "'AsyncHTMLContent' cannot run in synchronous context.")
extension AsyncHTMLContent: HTML where Content: HTML {}
