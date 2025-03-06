import SwiftSyntax
import SwiftSyntaxMacros

private let libraryName: StaticString = "Vue"
private let macroName: StaticString = "Reactive"
private let qualifiedMacroName = "@\(libraryName).\(macroName)"

public struct ReactiveMacro: PeerMacro {
  public static func expansion(
    of _: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in _: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
      throw SwiftSyntaxMacros.MacroExpansionErrorMessage("`\(qualifiedMacroName)` can only be used in a variable.")
    }

    return try [
      DeclSyntax(variableDecl.projected())
    ]
  }
}

extension VariableDeclSyntax {
  fileprivate func projected() throws -> Self {
    guard case let .keyword(key) = bindingSpecifier.tokenKind, key == .let, let bindings = try bindings.projected() else {
      throw SwiftSyntaxMacros.MacroExpansionErrorMessage("`\(qualifiedMacroName)` can only be applied to a 'let'")
    }
    return VariableDeclSyntax(
      leadingTrivia: leadingTrivia,
      modifiers: modifiers,
      bindingSpecifier: TokenSyntax(
        .keyword(.var),
        trailingTrivia: .space,
        presence: .present
      ),
      bindings: bindings,
      trailingTrivia: trailingTrivia
    )
  }
}

extension PatternBindingListSyntax {
  fileprivate func projected() throws -> Self? {
    var bindings = self
    for index in bindings.indices {
      bindings[index] = try bindings[index].projected()
    }
    return bindings
  }
}

extension PatternBindingSyntax {
  fileprivate func projected() throws -> Self {
    guard let identifier = pattern.as(IdentifierPatternSyntax.self) else {
      throw SwiftSyntaxMacros.MacroExpansionErrorMessage("`\(qualifiedMacroName)` requires an identifier")
    }

    let reactiveVarID = TokenSyntax.identifier("_reactive")
    let contextVarID = TokenSyntax.identifier("_context")

    let accessorBlock = AccessorBlockSyntax(
      accessors: .getter(
        [
          /// Dependency initializer
          CodeBlockItemSyntax(
            item: .decl(
              DeclSyntax(
                VariableDeclSyntax(
                  attributes: [
                    .attribute(
                      AttributeSyntax(
                        attributeName: IdentifierTypeSyntax(name: .identifier("Dependencies.Dependency")),
                        leftParen: .leftParenToken(),
                        arguments: .argumentList(
                          LabeledExprListSyntax(
                            [
                              LabeledExprSyntax(
                                expression: MemberAccessExprSyntax(
                                  base: DeclReferenceExprSyntax(
                                    baseName: .identifier("Vue.VueElementContext")
                                  ),
                                  declName: DeclReferenceExprSyntax(baseName: .keyword(.self))
                                )
                              )
                            ]
                          )
                        ),
                        rightParen: .rightParenToken()
                      )
                    )
                  ],
                  bindingSpecifier: .keyword(.var),
                  bindings: [
                    PatternBindingSyntax(
                      pattern: IdentifierPatternSyntax(
                        identifier: contextVarID
                      )
                    )
                  ]
                )
              )
            )
          ),
          // Reactive initializer
          CodeBlockItemSyntax(
            item: .decl(
              DeclSyntax(
                VariableDeclSyntax(
                  bindingSpecifier: .keyword(.let),
                  bindings: [
                    PatternBindingSyntax(
                      pattern: IdentifierPatternSyntax(
                        identifier: reactiveVarID
                      ),
                      initializer: InitializerClauseSyntax(
                        equal: .equalToken(),
                        value: ExprSyntax(
                          FunctionCallExprSyntax(
                            calledExpression: DeclReferenceExprSyntax(baseName: .identifier("\(libraryName).\(macroName)")),
                            leftParen: .leftParenToken(),
                            arguments: [
                              LabeledExprSyntax(
                                label: .identifier("name"),
                                colon: .colonToken(),
                                expression: StringLiteralExprSyntax(
                                  openingQuote: .stringQuoteToken(),
                                  segments: [.stringSegment(StringSegmentSyntax(content: .stringSegment(identifier.identifier.trimmed.description)))],
                                  closingQuote: .stringQuoteToken()
                                ),
                                trailingComma: .commaToken()
                              ),
                              LabeledExprSyntax(
                                label: .identifier("value"),
                                colon: .colonToken(),
                                expression: MemberAccessExprSyntax(
                                  base: DeclReferenceExprSyntax(baseName: .keyword(.self)),
                                  period: .periodToken(),
                                  declName: DeclReferenceExprSyntax(baseName: identifier.identifier.trimmed)
                                )
                              ),
                            ],
                            rightParen: .rightParenToken()
                          )
                        )
                      )
                    )
                  ]
                )
              )
            )
          ),
          CodeBlockItemSyntax(
            item: .expr(
              ExprSyntax(
                FunctionCallExprSyntax(
                  calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: contextVarID),
                    declName: DeclReferenceExprSyntax(baseName: .identifier("addProperty"))
                  ),
                  leftParen: .leftParenToken(),
                  arguments: [
                    LabeledExprSyntax(
                      expression: DeclReferenceExprSyntax(
                        baseName: reactiveVarID
                      )
                    )
                  ],
                  rightParen: .rightParenToken()
                )
              )
            )
          ),
          // Return reactive
          CodeBlockItemSyntax(
            item: .stmt(
              StmtSyntax(
                ReturnStmtSyntax(
                  returnKeyword: .keyword(.return),
                  expression: ExprSyntax(
                    DeclReferenceExprSyntax(baseName: reactiveVarID)
                  )
                )
              )
            )
          ),
        ]
      )
    )

    return PatternBindingSyntax(
      leadingTrivia: leadingTrivia,
      pattern: IdentifierPatternSyntax(
        leadingTrivia: identifier.leadingTrivia,
        identifier: identifier.identifier.trimmed.prefixed("$"),
        trailingTrivia: nil
      ),
      typeAnnotation: TypeAnnotationSyntax(
        colon: .colonToken(),
        type: IdentifierTypeSyntax(name: .identifier("\(libraryName).\(macroName)"))
      ),
      accessorBlock: accessorBlock,
      trailingComma: trailingComma
    )
  }

  private func callReactiveFunc(
    identifier: IdentifierPatternSyntax,
    initializer: some ExprSyntaxProtocol
  ) -> some ExprSyntaxProtocol {
    FunctionCallExprSyntax(
      calledExpression: DeclReferenceExprSyntax(baseName: .identifier("\(libraryName).\(macroName)")),
      leftParen: .leftParenToken(),
      arguments: [
        LabeledExprSyntax(
          label: .identifier("name"),
          colon: .colonToken(),
          expression: StringLiteralExprSyntax(
            openingQuote: .stringQuoteToken(),
            segments: [.stringSegment(StringSegmentSyntax(content: .stringSegment(identifier.identifier.trimmed.description)))],
            closingQuote: .stringQuoteToken()
          ),
          trailingComma: .commaToken()
        ),
        LabeledExprSyntax(
          label: .identifier("value"),
          colon: .colonToken(),
          expression: initializer
        ),
      ],
      rightParen: .rightParenToken()
    )
  }
}
