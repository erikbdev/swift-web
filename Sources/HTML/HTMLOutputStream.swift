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

  /// Renders a HTML element
  /// 
  /// If content is `nil`, it will render the HTML element as a Self-Closing tag.
  /// - Parameters:
  ///   - tag: the HTML tag
  ///   - attributes: attributes associated with the tag
  ///   - content: if defined, create a HTML element with nested values, else create a Self-Enclosing tag
  // @_spi(Render)
  // @inlinable @inline(__always)
  // public mutating func appendTag(
  //   _ tag: consuming String, 
  //   attributes: consuming [HTMLAttribute],
  //   content: ((inout Self) -> Void)? = nil
  // ) {
  //   self.appendLeftAngle()  // <
  //   self.write(tag.utf8)  // tag-name
  //   for attr in attributes {
  //     self.write(0x20)  // space
  //     self.write(attr.name.utf8)  // <name>
  //     if let value = attr.value {
  //       self.write(0x3D)  // =
  //       self.write(0x22)  // "
  //       self.appendEscapedBytes(value.utf8, attributeMode: true)  // <value>
  //       self.write(0x22)  // "
  //     }
  //   }
  //   self.appendRightAngle()  // >
  //   if let content {
  //     content(&self)
  //     self.appendLeftAngle()  // <
  //     self.appendForwardSlash() // /
  //     self.write(tag.utf8)  // <tag-name>
  //     self.appendRightAngle() // >
  //   }
  // }

  // @_spi(Render)
  // @inlinable @inline(__always)
  // public mutating func appendLeftAngle() {
  //   self.write(0x3C)
  // }

  // @_spi(Render)
  // @inlinable @inline(__always)
  // public mutating func appendRightAngle() {
  //   self.write(0x3E)
  // }

  // @_spi(Render)
  // @inlinable @inline(__always)
  // public mutating func appendForwardSlash() {
  //   self.write(0x2F)
  // }

  // @_spi(Render)
  // @inlinable @inline(__always)
  // public mutating func appendEscapedBytes(
  //   _ bytes: consuming some Collection<UInt8>,
  //   attributeMode: Bool = false
  // ) {
  //   for byte in bytes {
  //     switch byte {
  //     case 0x28:                      // &
  //       self.write("&amp;".utf8)
  //     case 0x3C where !attributeMode: // <
  //       self.write("&lt;".utf8)
  //     case 0x3E where !attributeMode: // >
  //       self.write("&gt;".utf8)
  //     case 0x22 where attributeMode:  // "
  //       self.write("&quot;".utf8)
  //     case 0x27 where attributeMode:  // '
  //       self.write("&#39;".utf8)
  //     default: 
  //       self.write(byte)
  //     }
  //   }
  // }
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