//
//  Tuple.swift
//  SyntaxKit
//
//  Created by Leo Dion.
//  This file defines a `Tuple` code-block that generates a Swift tuple expression.
//  It is primarily useful for macro expansions or DSL code that needs to group
//  multiple expression `CodeBlock`s together, for example:
//
//     Tuple {
//       VariableExp("value")
//       Literal.string("debug")
//     }.expr   // -> ExprSyntax for `(value, "debug")`
//
//  The result is represented as a `TupleExprSyntax`, which naturally conforms to
//  `ExprSyntax` and therefore plays nicely with our `CodeBlock.expr` convenience.
//

import SwiftSyntax

/// A tuple expression, e.g. `(a, b, c)`.
public struct Tuple: CodeBlock {
  private let elements: [CodeBlock]

  /// Creates a tuple expression comprising the supplied elements.
  /// - Parameter content: A ``CodeBlockBuilder`` producing the tuple elements **in order**.
  /// Elements may be any `CodeBlock` that can be represented as an expression (see
  /// `CodeBlock.expr`).
  public init(@CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
    self.elements = content()
  }

  public var syntax: SyntaxProtocol {
    guard !elements.isEmpty else {
      fatalError("Tuple must contain at least one element.")
    }

    let list = TupleExprElementListSyntax(
      elements.enumerated().map { index, block in
        let elementExpr = block.expr
        return TupleExprElementSyntax(
          label: nil,
          colon: nil,
          expression: elementExpr,
          trailingComma: index < elements.count - 1 ? .commaToken(trailingTrivia: .space) : nil
        )
      }
    )

    let tupleExpr = ExprSyntax(
      TupleExprSyntax(
        leftParen: .leftParenToken(),
        elements: list,
        rightParen: .rightParenToken()
      )
    )

    return tupleExpr
  }
}
