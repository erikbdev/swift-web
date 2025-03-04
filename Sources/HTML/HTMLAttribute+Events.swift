public protocol HTMLEventValue: Sendable, Hashable, RawRepresentable, ExpressibleByStringLiteral {}

extension HTMLAttribute {
  public struct MouseEvent: HTMLEventValue {
    public var rawValue: String

    public init(stringLiteral value: String) {
      self.rawValue = value
    }

    public init(rawValue: String) {
      self.rawValue = rawValue
    }
  }

  public struct KeyboardEvent: HTMLEventValue {
    public var rawValue: String

    public init(stringLiteral value: String) {
      self.rawValue = value
    }

    public init(rawValue: String) {
      self.rawValue = rawValue
    }
  }

  public struct FormEvent: HTMLEventValue {
    public var rawValue: String

    public init(stringLiteral value: String) {
      self.rawValue = value
    }

    public init(rawValue: String) {
      self.rawValue = rawValue
    }
  }

  public static func on<Event: HTMLEventValue>(_ event: Event, _ script: String) -> Self {
    Self(name: "on\(event.rawValue)", value: script)
  }
}

extension HTMLEventValue where Self == HTMLAttribute.MouseEvent {
  public static var click: Self { #function }
  public static var dblclick: Self { #function }
  public static var mousedown: Self { #function }
  public static var mousemove: Self { #function }
  public static var mouseout: Self { #function }
  public static var mouseover: Self { #function }
  public static var mouseup: Self { #function }
  public static var wheel: Self { #function }
}

extension HTMLEventValue where Self == HTMLAttribute.KeyboardEvent {
  public static var keydown: Self { #function }
  public static var keypress: Self { #function }
  public static var keyup: Self { #function }
}

extension HTMLEventValue where Self == HTMLAttribute.FormEvent {
  public static var blur: Self { #function }
  public static var change: Self { #function }
  public static var contextmenu: Self { #function }
  public static var focus: Self { #function }
  public static var input: Self { #function }
  public static var invalid: Self { #function }
  public static var reset: Self { #function }
  public static var search: Self { #function }
  public static var select: Self { #function }
  public static var submit: Self { #function }
}
