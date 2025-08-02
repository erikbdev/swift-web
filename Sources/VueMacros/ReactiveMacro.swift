import SwiftSyntax
import SwiftSyntaxMacros

enum ReactiveMacro {
  static let qualifiedName = "Reactive"
  static let fullyQualifiedName = "Vue.\(qualifiedName)"
}

extension ReactiveMacro: PeerMacro {
  static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {

    guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
      throw MacroExpansionErrorMessage("`@\(qualifiedName)` can not be attached to \(declaration.description).")
    }

    guard variableDecl.bindingSpecifier.tokenKind == .keyword(.let) else {
      throw MacroExpansionErrorMessage("`@\(qualifiedName)` is only available in a `let` binding.")
    }

    guard let binding = variableDecl.bindings.first, binding.accessorBlock == nil else {
      throw MacroExpansionErrorMessage("`@\(qualifiedName)` can not be attached to a property with an accessor block.")
    }

    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed else {
      throw MacroExpansionErrorMessage("`@\(qualifiedName)` must have an identifier.")
    }

    return [
      DeclSyntax(
        VariableDeclSyntax(
          modifiers: variableDecl.modifiers,
          bindingSpecifier: .keyword(binding.initializer == nil ? .var : .let),
          bindings: [
            PatternBindingSyntax(
              pattern: PatternSyntax(IdentifierPatternSyntax(identifier: identifier.prefixed("$"))),
              typeAnnotation: binding.typeAnnotation.flatMap { typeAnnotation in
                TypeAnnotationSyntax(
                  type: MemberTypeSyntax(
                    baseType: IdentifierTypeSyntax(name: .identifier("Vue")),
                    period: .periodToken(),
                    name: .identifier("Expression"),
                    genericArgumentClause: GenericArgumentClauseSyntax(
                      leftAngle: .leftAngleToken(),
                      rightAngle: .rightAngleToken()
                    ) {
                      GenericArgumentSyntax(argument: typeAnnotation.type)
                    }
                  )
                )
              },
              initializer: binding.initializer.flatMap {
                InitializerClauseSyntax(
                  value: FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(
                      base: DeclReferenceExprSyntax(baseName: .identifier("Vue")),
                      period: .periodToken(),
                      name: .identifier("Expression")
                    ),
                    leftParen: .leftParenToken(),
                    arguments: [
                      LabeledExprSyntax(
                        label: "name",
                        colon: .colonToken(),
                        expression: StringLiteralExprSyntax(
                          content: identifier.trimmed.text
                        ),
                        trailingComma: .commaToken()
                      ),
                      LabeledExprSyntax(
                        label: "value",
                        expression: $0.value
                      ),
                    ],
                    rightParen: .rightParenToken()
                  )
                )
              },
              accessorBlock: binding.initializer == nil
                ? AccessorBlockSyntax(
                  accessors: .getter([
                    CodeBlockItemSyntax(
                      item: .expr(
                        ExprSyntax(
                          FunctionCallExprSyntax(
                            calledExpression: MemberAccessExprSyntax(
                              base: DeclReferenceExprSyntax(baseName: .identifier("Vue")),
                              period: .periodToken(),
                              name: .identifier("Expression")
                            ),
                            leftParen: .leftParenToken(),
                            arguments: LabeledExprListSyntax(
                              [
                                LabeledExprSyntax(
                                  label: "name",
                                  colon: .colonToken(),
                                  expression: StringLiteralExprSyntax(
                                    content: identifier.trimmed.text
                                  ),
                                  trailingComma: .commaToken()
                                ),
                                LabeledExprSyntax(
                                  label: "value",
                                  expression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(baseName: .keyword(.`self`)),
                                    name: identifier.trimmed
                                  )
                                ),
                              ]
                            ),
                            rightParen: .rightParenToken()
                          )
                        )
                      )
                    )
                  ])
                ) : nil
            )
          ]
        )
      )
    ]
  }
}
