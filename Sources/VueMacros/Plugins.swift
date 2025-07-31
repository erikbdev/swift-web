import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
  var providingMacros: [any Macro.Type] = [
    VueScopeMacro.self,
    VueComponentMacro.self,
    ReactiveMacro.self
  ]
}
