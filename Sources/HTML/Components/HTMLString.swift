/// Renders HTML text without escaping characters.
/// This is a typealias of ``HTMLString(raw:)``
public let HTMLRaw = HTMLString.init(raw:)

/// Renders HTML text and escapes characters.
/// This is a typealias of ``HTMLString(_:)``
public let HTMLText = HTMLString.init(_:)

@resultBuilder
public struct HTMLString: HTML, Sendable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
  private var _storage: [StorageValue]

  @inlinable @inline(__always)
  public init(stringLiteral value: consuming String) {
    self.init(value)
  }

  @inlinable @inline(__always)
  public init(raw string: consuming String) {
    self.init(string.utf8, escape: false)
  }

  @inlinable @inline(__always)
  public init(_ string: consuming String) {
    self.init(string.utf8, escape: true)
  }

  public init(stringInterpolation: consuming StringInterpolation) {
    self._storage = stringInterpolation._storage
  }

  @usableFromInline
  init(_ bytes: consuming some Sequence<UInt8>, escape: Bool) {
    self._storage = [StorageValue(bytes, escape: escape)]
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) {
    for value in html._storage {
      switch value.element {
      case .bytes(let bytes):
        for byte in bytes {
          switch byte {
          case 0x26 where value.escape:  // &
            output.write("&amp;".utf8)
          case 0x3C where value.escape:  // <
            output.write("&lt;".utf8)
          default:
            output.write(byte)
          }
        }
      case .html(let html):
        withUnsafeMutablePointer(to: &output) { output in
          var proxy = _HTMLByteStreamProxy { bytes in
            for byte in bytes {
              switch byte {
              case 0x26 where value.escape:  // &
                output.pointee.write("&amp;".utf8)
              case 0x3C where value.escape:  // <
                output.pointee.write("&lt;".utf8)
              default:
                output.pointee.write(byte)
              }
            }
          }
          AnyHTMLSendable._render(html, into: &proxy)
        }
      }
    }
  }

  @_spi(Render)
  public static func _render<Output: HTMLByteStream>(
    _ html: consuming Self,
    into output: inout Output
  ) async throws {
    func _render(_ html: consuming Self) {
      Self._render(html, into: &output)
    }
    _render(html)
  }

  public var body: Never { fatalError() }
}

extension HTMLString {
  public struct StringInterpolation: StringInterpolationProtocol {
    fileprivate var _storage: [StorageValue]

    public init(literalCapacity: Int, interpolationCount: Int) {
      self._storage = []
    }

    public mutating func appendLiteral(_ value: consuming String) {
      _storage.append(.init(value.utf8, escape: true))
    }

    public mutating func appendInterpolation(_ value: consuming String) {
      _storage.append(.init(value.utf8, escape: true))
    }

    public mutating func appendInterpolation<Content: HTML & Sendable>(_ html: consuming Content) {
      _storage.append(.init(html, escape: true))
    }

    public mutating func appendInterpolation(raw value: consuming String) {
      _storage.append(.init(value.utf8, escape: false))
    }

    public mutating func appendInterpolation<Content: HTML & Sendable>(raw html: consuming Content) {
      _storage.append(.init(html, escape: false))
    }
  }
}

private struct StorageValue: Sendable {
  let element: Element
  let escape: Bool

  init<S: Sequence<UInt8>>(_ bytes: S, escape: Bool) {
    self.element = .bytes(ContiguousArray(bytes))
    self.escape = escape
  }

  init<T: HTML & Sendable>(_ html: T, escape: Bool) {
    self.element = .html(AnyHTMLSendable(html))
    self.escape = escape
  }

  enum Element: Sendable {
    case bytes(ContiguousArray<UInt8>)
    case html(AnyHTMLSendable)
  }
}

private struct _HTMLByteStreamProxy: HTMLByteStream {
  let callback: (ContiguousArray<UInt8>) -> Void

  mutating func write(_ byte: consuming UInt8) {        
  }

  mutating func write(_ bytes: consuming some Sequence<UInt8>) {
    callback(ContiguousArray(bytes))
  }
}

// Result builder
extension HTMLString {
  @inlinable @inline(__always)
  public static func buildPartialBlock(first: String) -> String {
    first
  }

  @inlinable @inline(__always)
  public static func buildPartialBlock(accumulated: String, next: String) -> String {
    accumulated + "\n" + next
  }

  @inlinable @inline(__always)
  public static func buildEither(first component: String) -> String {
    component
  }

  @inlinable @inline(__always)
  public static func buildEither(second component: String) -> String {
    component
  }

  @inlinable @inline(__always)
  public static func buildOptional(_ component: String?) -> String {
    component ?? ""
  }

  @inlinable @inline(__always)
  public static func buildArray(_ components: [String]) -> String {
    components.joined(separator: "\n")
  }
}
