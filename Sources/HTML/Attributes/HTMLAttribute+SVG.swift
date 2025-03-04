extension HTMLAttribute {
  public static func xmlns(_ value: String = "http://www.w3.org/2000/svg") -> HTMLAttribute {
    Self(name: "xmlns", value: value)
  }

  public static func fill(_ value: String? = nil) -> Self {
    Self(name: "fill", value: value ?? "none")
  }

  public static func viewBox(_ value: String? = nil) -> Self {
    Self(name: "viewBox", value: value ?? "none")
  }

  public static func strokeWidth(_ value: String) -> Self {
    Self(name: "strokeWidth", value: value)
  }

  public static func stroke(_ value: String) -> Self {
    Self(name: "stroke", value: value)
  }

  public static func width(_ value: String) -> Self {
    Self(name: "width", value: value)
  }

  public static func height(_ value: String) -> Self {
    Self(name: "width", value: value)
  }
}

/// <path> tag
extension HTMLAttribute {
  public static func strokeLinecap(_ value: String) -> Self {
    Self(name: "stroke-linecap", value: value)
  }

  public static func strokeLinejoin(_ value: String) -> Self {
    Self(name: "stroke-linejoin", value: value)
  }

  public static func d(_ value: String) -> Self {
    Self(name: "d", value: value)
  }

  public static func fillRule(_ value: String) -> Self {
    Self(name: "fill-rule", value: value)
  }

  public static func clipRule(_ value: String) -> Self {
    Self(name: "clip-rule", value: value)
  }
}
