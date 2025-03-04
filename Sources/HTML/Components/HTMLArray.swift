public struct _HTMLArray<Element: HTML>: HTML {
  let elements: [Element]

  public static func _render<Output: HTMLOutputStream>(
    _ html: consuming Self, 
    into output: inout Output
  ) {
    for element in html.elements {
      Element._render(element, into: &output)
    }
  }

  public var body: Never { fatalError() }
}