import SwiftSyntax

extension TokenSyntax {
  func prefixed(_ prefix: String) -> Self {
    switch tokenKind {
    case let .identifier(identity):
      TokenSyntax(
        .identifier(prefix + identity),
        leadingTrivia: leadingTrivia,
        trailingTrivia: trailingTrivia,
        presence: presence
      )
    default: self
    }
  }
}

extension PatternBindingListSyntax {
  var isComputed: Bool {
    self.contains { $0.accessorBlock?.accessors.is(CodeBlockItemListSyntax.self) ?? false } 
  }
}
