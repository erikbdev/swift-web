import Dependencies
import DependenciesMacros

public protocol HTMLOutputStream {
  mutating func write(_ bytes: consuming some Collection<UInt8>)
  mutating func write(_ byte: UInt8)
}

extension HTMLOutputStream {
  public mutating func write<S: Sequence<UInt8>>(sequence: S) {
    for byte in sequence {
      self.write(byte)
    }
  }
}

extension String: HTMLOutputStream {
  @inlinable @inline(__always)
  public mutating func write(_ byte: UInt8) {
    self.write([byte])
  }

  @inlinable @inline(__always)
  public mutating func write(_ bytes: consuming some Collection<UInt8>) {
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
  public consuming func render<Output: HTMLOutputStream>(into output: inout Output) {
    Self._render(self, into: &output)
  }
}