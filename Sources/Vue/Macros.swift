import HTML

@freestanding(expression)
public macro VueScope<each Input: Encodable, Content: AsyncHTML>(
  _ initialValues: repeat each Input,
  @HTMLBuilder content: (repeat Expression<each Input>) -> Content
) -> HTMLAttributes<HTMLElement<Content>> = #externalMacro(module: "VueMacros", type: "VueScopeMacro")

@attached(member, names: named(allProps))
@attached(extension, conformances: Vue.Component)
public macro Component() = #externalMacro(module: "VueMacros", type: "VueComponentMacro")

@attached(peer, names: prefixed(`$`))
public macro Reactive() = #externalMacro(module: "VueMacros", type: "ReactiveMacro")