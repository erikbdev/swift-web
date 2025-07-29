import Dependencies

public protocol AsyncHTMLOutputStream {
  mutating func write<S: Sequence<UInt8>>(_ bytes: consuming S) async throws
}

public protocol HTMLOutputStream {
  mutating func write<S: Sequence<UInt8>>(_ bytes: consuming S)
}

extension AsyncHTMLOutputStream {
  mutating func write(_ byte: consuming UInt8) async throws {
    try await self.write([byte])
  }
}

extension HTMLOutputStream {
  mutating func write(_ byte: consuming UInt8) {
    self.write([byte])
  }
}

extension AsyncHTML {
  @inline(__always)
  public consuming func render() async throws -> String {
    var bytes = _HTMLBuffer()
    try await Self._render(self, into: &bytes)
    return String(decoding: bytes.bytes, as: UTF8.self)
  }

  @inline(__always)
  public consuming func render<Output: AsyncHTMLOutputStream>(into output: inout Output) async throws {
    try await Self._render(self, into: &output)
  }
}

extension HTML {
  @inline(__always)
  public consuming func render() -> String {
    var bytes = _HTMLBuffer()
    Self._render(self, into: &bytes)
    return String(decoding: bytes.bytes, as: UTF8.self)
  }

  @inline(__always)
  public consuming func render<Output: HTMLOutputStream>(into output: inout Output) {
    Self._render(self, into: &output)
  }
}
