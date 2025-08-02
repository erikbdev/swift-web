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
  public consuming func render(_ config: HTMLContext.Configuration = .minified) async throws -> String {
    try await withDependencies {
      $0.htmlContext = HTMLContext(config)
    } operation: { [self] in
      var bytes = _HTMLBuffer()
      try await Self._render(self, into: &bytes)
      return String(decoding: bytes.bytes, as: UTF8.self)
    }
  }

  @inline(__always)
  public consuming func render<Output: AsyncHTMLOutputStream>(_ config: HTMLContext.Configuration = .minified, into output: inout Output) async throws {
    try await withDependencies {
      $0.htmlContext = HTMLContext(config)
    } operation: { [self] in
      try await Self._render(self, into: &output)
    }
  }
}

extension HTML {
  @inline(__always)
  public consuming func render(_ config: HTMLContext.Configuration = .minified) -> String {
    withDependencies {
      $0.htmlContext = HTMLContext(config)
    } operation: { [self] in
      var bytes = _HTMLBuffer()
      Self._render(self, into: &bytes)
      return String(decoding: bytes.bytes, as: UTF8.self)
    }
  }

  @inline(__always)
  public consuming func render<Output: HTMLOutputStream>(_ config: HTMLContext.Configuration = .minified, into output: inout Output) {
    withDependencies {
      $0.htmlContext = HTMLContext(config)
    } operation: { [self] in
      Self._render(self, into: &output)
    }
  }
}
