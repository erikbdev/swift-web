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
      DeclSyntax(variableDecl.projected()),
    ]
  }

  private enum Error: Swift.Error {}
}

private extension VariableDeclSyntax {
  func projected() throws -> Self {
    if case let .keyword(key) = bindingSpecifier.tokenKind, key == .let, let bindings = try bindings.projected() {
      VariableDeclSyntax(
        leadingTrivia: leadingTrivia,
        modifiers: modifiers,
        bindingSpecifier: TokenSyntax(
          bindings.isComputed ? .keyword(.var) : .keyword(.let),
          trailingTrivia: .space,
          presence: .present
        ),
        bindings: bindings,
        trailingTrivia: trailingTrivia
      )
    } else {
      throw SwiftSyntaxMacros.MacroExpansionErrorMessage("`\(qualifiedMacroName)` can only be applied to a 'let'")
    }
  }
}

private extension PatternBindingListSyntax {
  func projected() throws -> Self? {
    var bindings = self
    for index in bindings.indices {
      bindings[index] = try bindings[index].projected()
    }
    return bindings
  }
}

private extension PatternBindingSyntax {
  func projected() throws -> Self {
    if let identifier = pattern.as(IdentifierPatternSyntax.self) {
      let initializer: InitializerClauseSyntax? = if let initializer = self.initializer?.value {
        InitializerClauseSyntax(value: callReactiveFunc(identifier: identifier, initializer: initializer))
      } else {
        nil
      }

      let accessorBlock: AccessorBlockSyntax? = if self.initializer?.value == nil {
        AccessorBlockSyntax(
          accessors: .getter([
            CodeBlockItemSyntax(
              item: .expr(
                ExprSyntax(
                  callReactiveFunc(
                    identifier: identifier,
                    initializer: MemberAccessExprSyntax(
                      base: DeclReferenceExprSyntax(baseName: .keyword(.self)),
                      period: .periodToken(),
                      declName: DeclReferenceExprSyntax(baseName: identifier.identifier.trimmed)
                    )
                  )
                )
              )
            ),
          ])
        )
      } else {
        nil
      }

      return PatternBindingSyntax(
        leadingTrivia: leadingTrivia,
        pattern: IdentifierPatternSyntax(
          leadingTrivia: identifier.leadingTrivia,
          identifier: identifier.identifier.trimmed.prefixed("$"),
          trailingTrivia: identifier.trailingTrivia
        ),
        typeAnnotation: accessorBlock.flatMap { _ in
           TypeAnnotationSyntax(
            colon: .colonToken(),
            type: IdentifierTypeSyntax(name: .identifier("\(libraryName).\(macroName)"))
          )
        },
        initializer: initializer,
        accessorBlock: accessorBlock,
        trailingComma: trailingComma
      )
    } else {
      throw SwiftSyntaxMacros.MacroExpansionErrorMessage("`\(qualifiedMacroName)` requires an identifier")
    }
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