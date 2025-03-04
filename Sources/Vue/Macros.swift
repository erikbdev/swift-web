@attached(peer, names: prefixed(`$`))
public macro Reactive() = #externalMacro(module: "VueMacros", type: "ReactiveMacro")

@attached(peer, names: prefixed(`$`))
public macro Statement() = #externalMacro(module: "VueMacros", type: "StatementMacro")
