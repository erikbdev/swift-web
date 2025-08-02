import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum VueComponentMacro {
  static let qualifiedName = "Component"
}

extension VueComponentMacro: MemberMacro {

  static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let structDecl = declaration.as(StructDeclSyntax.self) else {
      throw MacroExpansionErrorMessage("`@\(qualifiedName)` can only be attached to a struct.")
    }

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

      guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
        continue
      }

      let hasRefAttr = variableDecl.attributes.contains { element in
        guard case .attribute(let attr) = element else {
          return false
        }

        let attributeName = attr.attributeName.trimmedDescription

        return attributeName.starts(with: ReactiveMacro.qualifiedName) || attributeName.starts(with: ReactiveMacro.fullyQualifiedName)
      }

      guard hasRefAttr else {
        continue
      }

      allProps.append(identifier.trimmed)
    }

    let allPropsVariable = DeclSyntax(
      VariableDeclSyntax(
        modifiers: structDecl.modifiers.contains { $0.trimmedDescription == TokenSyntax.keyword(.public).trimmedDescription } ? [DeclModifierSyntax(name: .keyword(.public))] : [],
        bindingSpecifier: .keyword(.var),
        bindings: [
          PatternBindingSyntax(
            pattern: IdentifierPatternSyntax(
              identifier: .identifier("allProps")
            ),
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
                        )
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
                          name: .identifier("Expression")
                        ),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax(
                          zip(allProps.indices, allProps).compactMap { idx, identifier in
                            LabeledExprSyntax(
                              expression: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(baseName: .keyword(.self)),
                                period: .periodToken(),
                                name: identifier.prefixed("$")
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
      )
    )

    return [allPropsVariable]
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
    if let inheritanceClause = declaration.inheritanceClause,
      inheritanceClause.inheritedTypes.contains(where: { ["Vue.\(qualifiedName)", qualifiedName].contains($0.type.trimmedDescription) }) {
      return []
    }
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
                name: .identifier(qualifiedName)
              )
            )
          ]
        ),
        memberBlock: MemberBlockSyntax(members: [])
      )
    ]
  }
}
