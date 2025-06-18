//
//  CodeBlock+ExprSyntax.swift
//  SyntaxKit
//
//  Created by Leo Dion.
//  Provides convenience for converting a CodeBlock into ExprSyntax when appropriate.
//

import SwiftSyntax

extension CodeBlock {
  /// Attempts to treat this `CodeBlock` as an expression and return its `ExprSyntax` form.
  ///
  /// If the underlying syntax already *is* an `ExprSyntax`, it is returned directly. If the
  /// underlying syntax is a bare `TokenSyntax` (commonly the case for `VariableExp` which
  /// produces an identifier token), we wrap it in a `DeclReferenceExprSyntax` so that it becomes
  /// a valid expression node. Any other kind of syntax results in a runtime error, because it
  /// cannot be represented as an expression (e.g. declarations or statements).
  public var expr: ExprSyntax {
    if let expr = self.syntax.as(ExprSyntax.self) {
      return expr
    }

    if let token = self.syntax.as(TokenSyntax.self) {
      return ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(token.text)))
    }

    fatalError("CodeBlock of type \(type(of: self.syntax)) cannot be represented as ExprSyntax")
  }
}
