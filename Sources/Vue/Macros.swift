import HTML

@freestanding(expression)
public macro VueScope<each Input: Encodable, Content: HTML>(
  _ initialValues: repeat each Input,
  @HTMLBuilder content: (repeat Expression<each Input>) -> Content
) -> HTMLAttributes<HTMLElement<Content>> = #externalMacro(module: "VueMacros", type: "VueScopeMacro")

@attached(member, names: arbitrary, named(allProps))
@attached(extension, conformances: VueComponent)
public macro VueComponent() = #externalMacro(module: "VueMacros", type: "VueComponentMacro")