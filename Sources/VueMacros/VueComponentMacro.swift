import SwiftSyntax
import SwiftSyntaxMacros

struct VueComponentMacro {}

extension VueComponentMacro: MemberMacro {

  static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let structDecl = declaration.as(StructDeclSyntax.self) else {
      throw MacroExpansionErrorMessage("`@VueComponent` can only be attached to a struct.")
    }

    var members: [DeclSyntax] = []
    var allProps: [TokenSyntax] = []

    for member in structDecl.memberBlock.members {
      guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else {
        continue
      }

      guard variableDecl.bindingSpecifier.tokenKind == .keyword(.let) else {
        continue
      }

      guard let binding = variableDecl.bindings.first, binding.accessorBlock == nil else {
        continue
      }

      // members.append(variableDecl)

      guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed else {
        continue
      }

      allProps.append(identifier)
      members.append(
        DeclSyntax(
          VariableDeclSyntax(
            bindingSpecifier: .keyword(binding.initializer == nil ? .var : .let),
            bindings: [
              PatternBindingSyntax(
                pattern: PatternSyntax(IdentifierPatternSyntax(identifier: identifier.prefixed("$"))),
                typeAnnotation: binding.typeAnnotation.flatMap {
                  TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier("Vue.Expression<\($0.type.trimmed)>")))
                },
                initializer: binding.initializer.flatMap {
                  InitializerClauseSyntax(
                    value: FunctionCallExprSyntax(
                      calledExpression: DeclReferenceExprSyntax(baseName: .identifier("Vue.Expression")),
                      leftParen: .leftParenToken(),
                      arguments: [
                        LabeledExprSyntax(
                          label: "name",
                          colon: .colonToken(),
                          expression: StringLiteralExprSyntax(
                            openingQuote: .stringQuoteToken(),
                            segments: [.stringSegment(StringSegmentSyntax(content: identifier))],
                            closingQuote: .stringQuoteToken()
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
                accessorBlock: binding.initializer == nil ?
                  AccessorBlockSyntax(
                    accessors: .getter([
                      CodeBlockItemSyntax(
                        item: .expr(
                          ExprSyntax(
                            FunctionCallExprSyntax(
                              calledExpression: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(baseName: .identifier("Vue")),
                                period: .periodToken(),
                                name: .identifier("Expression"),
                              ),
                              leftParen: .leftParenToken(),
                              arguments: LabeledExprListSyntax(
                                [
                                  LabeledExprSyntax(
                                    label: "name",
                                    colon: .colonToken(),
                                    expression: StringLiteralExprSyntax(
                                      openingQuote: .stringQuoteToken(),
                                      segments: [.stringSegment(StringSegmentSyntax(content: identifier))],
                                      closingQuote: .stringQuoteToken()
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
      )
    }

    let allPropsVariable = DeclSyntax(
      VariableDeclSyntax(
        bindingSpecifier: .keyword(.var),
        bindings: [
          PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(identifier: .identifier("allProps")),
            typeAnnotation: TypeAnnotationSyntax(
              type: MemberTypeSyntax(
                baseType: IdentifierTypeSyntax(name: .identifier("Vue")),
                name: .identifier("Expression"),
                genericArgumentClause: GenericArgumentClauseSyntax(
                  leftAngle: .leftAngleToken(),
                  arguments: [
                    GenericArgumentSyntax(
                      argument: DictionaryTypeSyntax(
                        key: MemberTypeSyntax(
                          baseType: IdentifierTypeSyntax(name: .identifier("Swift")),
                          name: .identifier("String")
                        ),
                        value: MemberTypeSyntax(
                          baseType: IdentifierTypeSyntax(name: .identifier("Vue")),
                          name: .identifier("AnyEncodable")
                        ),
                      )
                    )
                  ],
                  rightAngle: .rightAngleToken()
                )
              )
            ),
            accessorBlock: AccessorBlockSyntax(
              accessors: .getter([
                CodeBlockItemSyntax(
                  item: .expr(
                    ExprSyntax(
                      FunctionCallExprSyntax(
                        calledExpression: MemberAccessExprSyntax(
                          base: DeclReferenceExprSyntax(baseName: .identifier("Vue")),
                          period: .periodToken(),
                          name: .identifier("Expression"),
                        ),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax(
                          zip(allProps.indices, allProps).compactMap { idx, identifier in
                            LabeledExprSyntax(
                              expression: TupleExprSyntax(
                                elements: [
                                  LabeledExprSyntax(
                                    expression: StringLiteralExprSyntax(
                                      openingQuote: .stringQuoteToken(),
                                      segments: [.stringSegment(StringSegmentSyntax(content: identifier.trimmed))],
                                      closingQuote: .stringQuoteToken()
                                    ),
                                    trailingComma: .commaToken()
                                  ),
                                  LabeledExprSyntax(
                                    expression: MemberAccessExprSyntax(
                                      base: DeclReferenceExprSyntax(baseName: .keyword(.`self`)),
                                      name: identifier.trimmed
                                    )
                                  ),
                                ]
                              ),
                              trailingComma: allProps.index(after: idx) < allProps.indices.upperBound ? .commaToken() : nil
                            )
                          }
                        ),
                        rightParen: .rightParenToken()
                      )
                    )
                  )
                )
              ])
            )
          )
        ]
      ),
    )

    return members + [allPropsVariable]
  }
}

extension VueComponentMacro: ExtensionMacro {
  static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
    conformingTo protocols: [SwiftSyntax.TypeSyntax],
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
    return [
      ExtensionDeclSyntax(
        extensionKeyword: .keyword(.extension),
        extendedType: type,
        inheritanceClause: InheritanceClauseSyntax(
          inheritedTypes: [
            InheritedTypeSyntax(
              type: MemberTypeSyntax(
                baseType: IdentifierTypeSyntax(name: .identifier("Vue")),
                period: .periodToken(), 
                name: .identifier("VueComponent")
              )
            )
          ]
        ),
        memberBlock: MemberBlockSyntax(members: [])
      )
    ]
  }
}
