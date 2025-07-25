import Dependencies

// public protocol AsyncHTMLByteStream {
//   mutating func write(_ byte: consuming UInt8) async throws
//   mutating func write<S: Sequence<UInt8>>(_ bytes: consuming S) async throws
// }

public protocol HTMLByteStream {
  mutating func write(_ byte: consuming UInt8)
  mutating func write<S: Sequence<UInt8>>(_ bytes: consuming S)
}

extension String: HTMLByteStream {
  @inlinable @inline(__always)
  public mutating func write(_ byte: consuming UInt8) {
    self.append(Character(Unicode.Scalar(byte)))
  }

  @inlinable @inline(__always)
  public mutating func write(_ bytes: consuming some Sequence<UInt8>) {
    self.append(String(decoding: Array(bytes), as: UTF8.self))
  }
}

extension AsyncHTML {
  @inline(__always)
  public consuming func render() async throws -> String {
    var result = ""
    try await Self._render(self, into: &result)
    return result
  }

  @inline(__always)
  public consuming func render<Output: HTMLByteStream>(into output: inout Output) async throws {
    try await Self._render(self, into: &output)
  }
}

extension HTML {
  @inline(__always)
  public consuming func render() -> String {
    var result = ""
    Self._render(self, into: &result)
    return result
  }

  @inline(__always)
  public consuming func render<Output: HTMLByteStream>(into output: inout Output) {
    Self._render(self, into: &output)
  }
}
