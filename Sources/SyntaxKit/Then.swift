import SwiftSyntax

/// A helper that represents the *final* `else` body in an `if` / `else-if` chain.
///
/// In the DSL this lets users write:
/// ```swift
/// If { condition } then: { ... } else: {
///   If { otherCond } then: { ... }
///   Then {             // <- final else
///     Call("print", "fallback")
///   }
/// }
/// ```
/// so that the builder can distinguish a nested `If` (for `else if`) from the
/// *terminal* `else` body.
public struct Then: CodeBlock {
  /// The statements that make up the `else` body.
  public let body: [CodeBlock]

  public init(@CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
    self.body = content()
  }

  public var syntax: SyntaxProtocol {
    let statements = CodeBlockItemListSyntax(
      body.compactMap { element in
        if let decl = element.syntax.as(DeclSyntax.self) {
          return CodeBlockItemSyntax(item: .decl(decl)).with(\.trailingTrivia, .newline)
        } else if let expr = element.syntax.as(ExprSyntax.self) {
          return CodeBlockItemSyntax(item: .expr(expr)).with(\.trailingTrivia, .newline)
        } else if let stmt = element.syntax.as(StmtSyntax.self) {
          return CodeBlockItemSyntax(item: .stmt(stmt)).with(\.trailingTrivia, .newline)
        }
        return nil
      }
    )

    return CodeBlockSyntax(
      leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
      statements: statements,
      rightBrace: .rightBraceToken(leadingTrivia: .newline)
    )
  }
} 