import HTML

@freestanding(expression)
public macro VueScope<each Input: Encodable, each Value, Content: HTML>(
  _ initialValues: repeat each Input,
  @HTMLBuilder content: (repeat each Value) -> Content
) -> HTMLAttributes<HTMLElement<Content>> = #externalMacro(module: "VueMacros", type: "VueScopeMacro")