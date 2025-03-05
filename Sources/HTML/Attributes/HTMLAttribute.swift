public struct HTMLAttribute: Hashable, Sendable {
  public let name: String
  public let value: String?
  public let mergeMode: MergeMode

  @inlinable @inline(__always)
  public init(name: String, value: String? = "", mergeMode: MergeMode = .replaceValue) {
    self.name = name
    self.value = value
    self.mergeMode = mergeMode
  }

  @usableFromInline
  init(_ name: String = #function, value: String? = "", mergeMode: MergeMode = .replaceValue) {
    self.name = name
    self.value = value
    self.mergeMode = mergeMode
  }

  @inlinable @inline(__always)
  public func callAsFunction(_ value: String? = "", mergeMode: MergeMode = .replaceValue) -> Self {
    Self(name: name, value: value, mergeMode: mergeMode)
  }

  public enum MergeMode: Sendable, Hashable {
    case replaceValue
    case mergeValue
    case ignoreIfSet
  }
}

// global attributes
extension HTMLAttribute {
  public static func custom(name: String, value: String) -> Self {
    Self(name: name, value: value)
  }

  public static var id: Self { Self() }

  public static var `class`: Self { Self() }

  public static var style: Self { Self() }

  public static func data(_ key: String, value: String) -> Self {
    Self(name: "data-\(key)", value: value)
  }

  public static var title: Self { Self() }

  public static var lang: Self { Self() }

  public static var hidden: Self { Self() }

  public static func tabindex(_ index: Int) -> Self {
    Self(name: "tabindex", value: "\(index)")
  }
}

// dir attribute
extension HTMLAttribute {
  public struct Direction: Hashable, Sendable, ExpressibleByStringLiteral, RawRepresentable {
    public var rawValue: String

    public init(stringLiteral value: String) {
      self.rawValue = value
    }

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public static var ltr: Self { #function }
    public static var rtl: Self { #function }
    public static var auto: Self { #function }
  }

  public static func dir(_ value: Direction) -> Self {
    Self(name: "dir", value: value.rawValue)
  }
}

// meta tag attributes
extension HTMLAttribute {
  public struct Name: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public var rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
      self.rawValue = value
    }

    public static var author: Name { #function }
    public static var description: Name { #function }
    public static var keywords: Name { #function }
    public static var viewport: Name { #function }
  }

  public static func name(_ name: Name) -> Self {
    Self(name: "name", value: name.rawValue)
  }

  public static var content: Self { Self() }

  public static var property: Self { Self() }
}

// link tag attributes
extension HTMLAttribute {
  public struct As: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public var rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral rawValue: String) {
      self.rawValue = rawValue
    }

    public static var audio: As { #function }
    public static var document: As { #function }
    public static var embed: As { #function }
    public static var fetch: As { #function }
    public static var font: As { #function }
    public static var image: As { #function }
    public static var object: As { #function }
    public static var script: As { #function }
    public static var style: As { #function }
    public static var track: As { #function }
    public static var video: As { #function }
    public static var worker: As { #function }
    public static var author: As { #function }
  }

  public static func `as`(_ value: As) -> Self {
    Self(name: "as", value: value.rawValue)
  }
}

// button tag attributes
extension HTMLAttribute {
  public struct ButtonType: Hashable, Sendable, ExpressibleByStringLiteral, RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }

    public static var submit: Self { #function }
    public static var reset: Self { #function }
    public static var button: Self { #function }
  }

  public static func type(_ button: ButtonType) -> Self {
    Self(name: "type", value: button.rawValue)
  }
}

extension HTMLAttribute {
  // href attribute
  public static var href: Self { Self() }

  // src attribute
  public static var src: Self { Self() }
}

// target attribute
extension HTMLAttribute {
  public struct Target: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }

    private init(_ value: String = #function) {
      self.rawValue = "_" + value
    }

    public static var blank: Self { Self() }
    public static var parent: Self { Self() }
    public static var `self`: Self { Self() }
    public static var top: Self { Self() }
  }

  public static func target(_ target: Target) -> Self {
    Self(name: "target", value: target.rawValue)
  }
}

// autofocus attribute
extension HTMLAttribute {
  public static var autofocus: Self { Self() }
}

// charset attribute
extension HTMLAttribute {
  public struct CharacterSet: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }

    public static var utf8: Self { "UTF-8" }
  }

  public static func charset(_ charset: CharacterSet) -> Self {
    Self(name: "charset", value: charset.rawValue)
  }
}

// rel attribute
extension HTMLAttribute {
  public struct Relationship: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }

    public static var icon: Self { #function }
    public static var stylesheet: Self { #function }
    public static var preload: Self { #function }
    public static var canonical: Self { #function }
  }

  public static func rel(_ relation: Relationship) -> Self {
    Self(name: "rel", value: relation.rawValue)
  }
}

extension HTMLAttribute {
  public static var required: Self { Self() }

  public static var disabled: Self { Self() }

  public static var alt: Self { Self() }
}

// autocomplete attribute
extension HTMLAttribute {
  public struct AutoComplete: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }

    public static var on: Self { #function }
    public static var off: Self { #function }
  }

  public static func autocomplete(_ autoComplete: AutoComplete) -> Self {
    Self(name: "autocomplete", value: autoComplete.rawValue)
  }
}

// label attribute
extension HTMLAttribute {
  public static var label: Self { Self() }
}

// form attribute
extension HTMLAttribute {
  public static var form: Self { Self() }
}

// name attribute (for basic string case, meta has its own typed name attribute)
extension HTMLAttribute {
  public static var name: Self { Self() }
}

// crossorigin attribute
extension HTMLAttribute {
  public struct CrossOrigin: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }

    public static var anonymous: Self { #function }
    public static var useCredentials: Self { "use-credentials" }
  }

  public static func crossorigin(_ origin: CrossOrigin) -> Self {
    Self(name: "crossorigin", value: origin.rawValue)
  }
}

// integrity attribute
extension HTMLAttribute {
  public static var integrity: Self { Self() }
}

// referrerpolicy attribute
extension HTMLAttribute {
  public struct ReferrerPolicy: Sendable, Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
      self.rawValue = value
    }

    public static var noReferrer: Self { "no-referrer" }
    public static var noReferrerWhenDowngrade: Self { "no-referrer-when-downgrade" }
    public static var origin: Self { #function }
    public static var originWhenCrossOrigin: Self { "origin-when-cross-origin" }
    public static var sameOrigin: Self { "same-origin" }
    public static var strictOrigin: Self { "strict-origin" }
    public static var strictOriginWhenCrossOrigin: Self { "strict-origin-when-cross-origin" }
    public static var unsafeUrl: Self { "unsafe-url" }
  }

  public static func referrerPolicy(_ policy: ReferrerPolicy) -> Self {
    Self(name: "referrerpolicy", value: policy.rawValue)
  }
}

// width and height attributes
extension HTMLAttribute {
  public static func width(_ value: Int) -> Self {
    Self(name: "width", value: String(value))
  }

  public static func height(_ value: Int) -> Self {
    Self(name: "height", value: String(value))
  }
}

// form tag attributes
extension HTMLAttribute {
  public struct Method: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }

    public static var get: Self { #function }
    public static var post: Self { #function }
  }

  public static func method(_ method: Method) -> Self {
    Self(name: "method", value: method.rawValue)
  }

  public static var action: Self { Self() }
}

// input tag attrributes
extension HTMLAttribute {
  public struct InputType: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public var rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }

    public static var button: Self { #function }
    public static var checkbox: Self { #function }
    public static var color: Self { #function }
    public static var date: Self { #function }
    public static var datetimeLocal: Self { "datetime-local" }
    public static var email: Self { #function }
    public static var file: Self { #function }
    public static var hidden: Self { #function }
    public static var image: Self { #function }
    public static var month: Self { #function }
    public static var number: Self { #function }
    public static var password: Self { #function }
    public static var radio: Self { #function }
    public static var range: Self { #function }
    public static var reset: Self { #function }
    public static var search: Self { #function }
    public static var submit: Self { #function }
    public static var tel: Self { #function }
    public static var text: Self { #function }
    public static var time: Self { #function }
    public static var url: Self { #function }
    public static var week: Self { #function }
  }

  public static func type(_ type: InputType) -> Self {
    Self(name: "type", value: type.rawValue)
  }

  public static func value(_ value: String) -> Self {
    Self(name: "value", value: value)
  }

  public static var checked: Self { Self() }

  public static func accept(_ type: String) -> Self {
    Self(name: "accept", value: type)
  }
}

// label tag attributes
extension HTMLAttribute {
  public static var `for`: Self { Self() }
}

// option tag attributes
extension HTMLAttribute {
  public static var value: Self { Self() }

  public static var selected: Self { Self() }
}

// script tag attributes
extension HTMLAttribute {
  // type
  public struct ScriptType: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public var rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }

    public static var importmap: Self { #function }
    public static var module: Self { #function }
    public static var speculationrules: Self { #function }
  }

  public static func type(_ type: ScriptType) -> Self {
    HTMLAttribute(name: "type", value: type.rawValue)
  }

  // async
  public static var async: Self { Self() }

  // defer
  public static var `defer`: Self { Self() }

  // nomodule
  public static var nomodule: Self { Self() }
}

// placeholder attribute
extension HTMLAttribute {
  public static func placeholder(_ value: String) -> Self {
    Self(name: "placeholder", value: value)
  }
}

// scope attribute
extension HTMLAttribute {
  public struct Scope: Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public var rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
      self.rawValue = value
    }

    public static var col: Self { #function }
    public static var row: Self { #function }
    public static var colgroup: Self { #function }
    public static var rowgroup: Self { #function }
  }

  public static func scope(_ scope: Scope) -> Self {
    Self(name: "scope", value: scope.rawValue)
  }
}
