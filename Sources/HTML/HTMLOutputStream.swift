import Dependencies

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
    // withDependencies {
    //   $0.htmlContext = HTMLContext(config: $0.htmlConfig)
    // } operation: { [self] in
    Self._render(self, into: &result)
    // }
    return result
  }

  @inline(__always)
  public consuming func render<Output: HTMLOutputStream>(into output: inout Output) {
    // withDependencies {
    //   $0.htmlContext = HTMLContext(config: $0.htmlConfig)
    // } operation: { [self] in
    Self._render(self, into: &output)
    // }
  }
}

public struct HTMLOutputConfig: Sendable {
  let indentation: String
  let newLine: String

  public static let minified = Self(indentation: "", newLine: "")
  public static let pretty = Self(indentation: "  ", newLine: "\n")
}

extension HTMLOutputConfig: DependencyKey {
  public static let liveValue = Self.minified
  public static let testValue = Self.pretty
  public static let previewValue = Self.pretty
}

extension DependencyValues {
  public var htmlConfig: HTMLOutputConfig {
    get { self[HTMLOutputConfig.self] }
    set { self[HTMLOutputConfig.self] = newValue }
  }
}
