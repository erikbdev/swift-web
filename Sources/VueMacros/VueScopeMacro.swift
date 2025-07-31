import SwiftSyntax
import SwiftSyntaxMacros

struct VueScopeMacro {}

extension VueScopeMacro: ExpressionMacro {
  static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    guard let originalClosure = node.trailingClosure else {
      throw MacroExpansionErrorMessage("`#VueScope` requires a closure")
    }

    let allLabeledArguments: [TokenSyntax] =
      originalClosure.signature?.parameterClause.flatMap { clause in
        switch clause {
        case .simpleInput(let closure):
          closure.map(\.name.trimmed)
        case .parameterClause(let closure):
          closure.parameters.map(\.firstName.trimmed)
        }
      } ?? []

    guard allLabeledArguments.count == node.arguments.count else {
      throw MacroExpansionErrorMessage("`#VueScope` requires same number of arguments in closure")
    }

    let allArgumentExpressions = node.arguments.map(\.expression)
    guard allArgumentExpressions.count > 0 else {
      throw MacroExpansionErrorMessage("`#VueScope` requires arguments")
    }

    let allExpressions = zip(allLabeledArguments, allArgumentExpressions)
      .map { identifier, expression in
        CodeBlockItemSyntax(
          item: .decl(
            DeclSyntax(
              VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: [
                  PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                      leadingTrivia: .space,
                      identifier: identifier
                    ),
                    initializer: InitializerClauseSyntax(
                      equal: .equalToken(),
                      value: FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(baseName: .identifier("Vue.Expression")),
                        leftParen: .leftParenToken(),
                        arguments: [
                          LabeledExprSyntax(
                            label: "name",
                            colon: .colonToken(),
                            expression: StringLiteralExprSyntax(
                              openingQuote: .stringQuoteToken(),
                              segments: [
                                .stringSegment(
                                  StringSegmentSyntax(
                                    leadingTrivia: [.spaces(0)],
                                    content: identifier,
                                    trailingTrivia: [.spaces(0)]
                                  )
                                )
                              ],
                              closingQuote: .stringQuoteToken()
                            ),
                            trailingComma: .commaToken()
                          ),
                          LabeledExprSyntax(
                            label: "value",
                            colon: .colonToken(),
                            expression: expression
                          ),
                        ],
                        rightParen: .rightParenToken()
                      )
                    )
                  )
                ]
              )
            )
          )
        )
      }

    return ExprSyntax(
      FunctionCallExprSyntax(
        calledExpression: ClosureExprSyntax {
          allExpressions
          ReturnStmtSyntax(
            returnKeyword: .keyword(.return),
            expression: FunctionCallExprSyntax(
              calledExpression: DeclReferenceExprSyntax(
                baseName: .identifier("div")
              ),
              leftParen: .leftParenToken(),
              arguments: [
                LabeledExprSyntax(
                  label: nil,
                  expression: FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(
                      base: MemberAccessExprSyntax(
                        base: ExprSyntax?.none,
                        period: .periodToken(),
                        declName: DeclReferenceExprSyntax(baseName: .identifier("v"))
                      ),
                      period: .periodToken(),
                      declName: DeclReferenceExprSyntax(baseName: .identifier("scope"))
                    ),
                    leftParen: .leftParenToken(),
                    arguments: [
                      LabeledExprSyntax(
                        label: nil,
                        expression: FunctionCallExprSyntax(
                          calledExpression: DeclReferenceExprSyntax(baseName: .identifier("Vue.Expression")),
                          leftParen: .leftParenToken(),
                          arguments: LabeledExprListSyntax(
                            allLabeledArguments
                              .enumerated()
                              .map { idx, identifier in
                                LabeledExprSyntax(
                                  label: nil,
                                  expression: DeclReferenceExprSyntax(baseName: identifier),
                                  trailingComma: allLabeledArguments.index(after: idx) >= allLabeledArguments.endIndex ? nil : .commaToken()
                                )
                              }
                          ),
                          rightParen: .rightParenToken()
                        )
                      )
                    ],
                    rightParen: .rightParenToken()
                  )
                )
              ],
              rightParen: .rightParenToken(),
              trailingClosure: ClosureExprSyntax(
                statements: originalClosure.statements
              )
            )
          )
        },
        leftParen: .leftParenToken(),
        arguments: [],
        rightParen: .rightParenToken()
      )
    )
  }
}
