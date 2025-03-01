public struct HTMLAttribute {
  public let name: String
  public let value: String?

  public init(name: String, value: String? = "") {
    self.name = name
    self.value = value
  }
}

extension HTMLAttribute {
  public static func `class`(_ value: String) -> Self {
    Self(name: "class", value: value)
  }

  public static func style(_ value: String) -> Self {
    Self(name: "style", value: value)
  }
}

extension HTML {
  public func attribute(_ name: String, value: String? = "") -> Self {
    self
  }

  public func attribute(_ attribute: HTMLAttribute) -> Self {
    self
  }
}