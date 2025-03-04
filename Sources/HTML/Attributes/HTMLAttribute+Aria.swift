extension HTMLAttribute {
  /// A namespace for Aria attributes.
  /// See the [Aria attributes](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA) for more information.

  public struct Aria {}

  public static var aria: Aria { Aria() }
}

extension HTMLAttribute.Aria {
  public func label(_ value: String) -> HTMLAttribute {
    custom(name: "label", value: value)
  }

  public func current(_ value: String) -> HTMLAttribute {
    custom(name: "current", value: value)
  }

  public func selected(_ value: Bool?) -> HTMLAttribute {
    custom(name: "selected", value: value == true ? "true" : value == false ? "false" : "undefined")
  }

  public func custom(
    name: String,
    value: String? = ""
  ) -> HTMLAttribute {
    .init(name: "aria-\(name)", value: value)
  }
}