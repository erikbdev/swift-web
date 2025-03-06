import Dependencies

public protocol HTMLByteStream {
  mutating func write(_ bytes: consuming UnsafeBufferPointer<UInt8>)
}

extension HTMLByteStream {
  public mutating func write(_ byte: UInt8) {
    [byte].withUnsafeBufferPointer { self.write($0)  }
  }
}

extension String: HTMLByteStream {
  @inlinable @inline(__always)
  public mutating func write(_ bytes: consuming UnsafeBufferPointer<UInt8>) {
    self.append(String(decoding: bytes, as: UTF8.self))
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