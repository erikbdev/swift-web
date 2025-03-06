@attached(peer, names: prefixed(`$`))
public macro Reactive() = #externalMacro(module: "VueMacros", type: "ReactiveMacro")