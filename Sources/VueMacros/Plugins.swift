import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
  var providingMacros: [any Macro.Type] = [
    ReactiveMacro.self,
    StatementMacro.self,
  ]
}
