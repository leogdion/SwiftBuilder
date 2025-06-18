//
//  Tuple.swift
//  SyntaxKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
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
