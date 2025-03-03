public struct HTMLString: HTML, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
  internal var _storage: [Value]

  @inlinable @inline(__always)
  public init(stringLiteral value: consuming String) {
    self.init(value)
  }

  @inline(__always)
  public init(raw string: consuming String) {
    self.init(string.utf8, escape: false)
  }

  @inline(__always)
  public init(_ string: consuming String) {
    self.init(string.utf8, escape: true)
  }

  @inline(__always)
  init(_ bytes: consuming some Sequence<UInt8>, escape: Bool) {
    self._storage = [Value(bytes, escape: escape)]
  }

  public init(stringInterpolation: consuming StringInterpolation) {
    self._storage = stringInterpolation.storage
  }

  @_spi(Render) @inline(__always)
  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self, 
    into output: inout Output
  ) {
    for value in html._storage {
      switch value.element {
        case .bytes(let bytes):
          for byte in bytes {
            switch byte {
            case 0x26 where value.escape: // &
              output.write("&amp;".utf8)
            case 0x3C where value.escape: // <
              output.write("&lt;".utf8)
            default:
              output.write(byte)
            }
          }
        case .html(let html):
          withUnsafeMutablePointer(to: &output) { output in
            var proxy = _HTMLOutputStreamProxy { bytes in
              for byte in bytes {
              switch byte {
                case 0x26 where value.escape: // &
                  output.pointee.write("&amp;".utf8)
                case 0x3C where value.escape: // <
                  output.pointee.write("&lt;".utf8)
                default:
                  output.pointee.write(byte)
                }
              }
            }
            AnyHTML._render(html, into: &proxy)
          }
      }
    }
  }

  public var body: Never { fatalError() }
}

extension HTMLString {
  internal struct Value {
    let element: Element
    let escape: Bool

    init<S: Sequence<UInt8>>(_ bytes: S, escape: Bool) {
      self.element = .bytes(ContiguousArray(bytes)) 
      self.escape = escape
    }

    init<T: HTML>(_ html: T, escape: Bool) {
      self.element = .html(AnyHTML(html))
      self.escape = escape
    }

    enum Element {
      case bytes(ContiguousArray<UInt8>)
      case html(AnyHTML)
    }
  }

  private struct _HTMLOutputStreamProxy: HTMLOutputStream {
    let callback: (ContiguousArray<UInt8>) -> Void

    mutating func write(_ bytes: consuming some Collection<UInt8>) {
      callback(ContiguousArray(bytes))
    }

    mutating func write(_ byte: UInt8) {
      callback([byte])
    }
  }

  public struct StringInterpolation: StringInterpolationProtocol {
    fileprivate var storage: [Value]

    public init(literalCapacity: Int, interpolationCount: Int) {
      self.storage = []
    }

    public mutating func appendLiteral(_ value: String) {
      storage.append(Value(value.utf8, escape: true))
    }

    public mutating func appendInterpolation(_ value: String) {
      storage.append(Value(value.utf8, escape: true))
    }

    public mutating func appendInterpolation<Content: HTML>(_ html: Content) {
      storage.append(Value(html, escape: true))
    }

    public mutating func appendInterpolation(raw value: String) {
      storage.append(Value(value.utf8, escape: false))
    }

    public mutating func appendInterpolation<Content: HTML>(raw html: Content) {
      storage.append(Value(html, escape: false))
    }
  }
}

/// Renders HTML text without escaping characters.
/// This is a typealias of ``HTMLString(raw:)``
public let HTMLRaw = HTMLString.init(raw:)

/// Renders HTML text and escapes characters.
/// This is a typealias of ``HTMLString(_:)``
public let HTMLText = HTMLString.init(_:)