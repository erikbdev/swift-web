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

    guard let originalClosureSignature = originalClosure.signature else {
      throw MacroExpansionErrorMessage("`#VueScope` requires labels in parameter signature")
    }

    let allLabeledArguments: [TokenSyntax] =
      originalClosureSignature.parameterClause.flatMap { clause in
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

    let allReactives = zip(allLabeledArguments, allArgumentExpressions)
      .map { identifier, expression in
        TupleExprSyntax(
          leftParen: .leftParenToken(),
          elements: [
            LabeledExprSyntax(
              expression: StringLiteralExprSyntax(
                openingQuote: .stringQuoteToken(),
                segments: [.stringSegment(StringSegmentSyntax(content: identifier))],
                closingQuote: .stringQuoteToken()
              ),
              trailingComma: .commaToken()
            ),
            LabeledExprSyntax(
              expression: expression
            ),
          ],
          rightParen: .rightParenToken()
        )
      }

    let expressionObject = FunctionCallExprSyntax(
      calledExpression: DeclReferenceExprSyntax(baseName: .identifier("Vue.Expression")),
      leftParen: .leftParenToken(),
      arguments: LabeledExprListSyntax(
        allReactives.indices
          .map { idx in
            LabeledExprSyntax(
              label: nil,
              expression: allReactives[idx],
              trailingComma: allReactives.index(after: idx) >= allReactives.endIndex ? nil : .commaToken()
            )
          }
      ),
      rightParen: .rightParenToken()
    )

    let allExpressions = allLabeledArguments.map { identifier in
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
                    label: "rawValue",
                    colon: .colonToken(),
                    expression: StringLiteralExprSyntax(
                      openingQuote: .stringQuoteToken(),
                      segments: [.stringSegment(StringSegmentSyntax(content: identifier))],
                      closingQuote: .stringQuoteToken()
                    )
                  )
                ],
                rightParen: .rightParenToken()
              )
            )
          )
        ]
      )
    }

    let allExpressionsCodeBlock = CodeBlockItemListSyntax(
      allExpressions.map {
        CodeBlockItemSyntax(
          item: .decl(DeclSyntax($0))
        )
      }
    )

    return """
      div(.v.scope(\(expressionObject))) {
        \(allExpressionsCodeBlock)
        \(originalClosure.statements)
      }
      """
  }
}
