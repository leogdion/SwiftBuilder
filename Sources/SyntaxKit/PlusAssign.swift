//
//  PlusAssign.swift
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

/// A `+=` expression.
public struct PlusAssign: CodeBlock {
  private let target: String
  private let value: String

  /// Creates a `+=` expression.
  /// - Parameters:
  ///   - target: The variable to assign to.
  ///   - value: The value to add and assign.
  public init(_ target: String, _ value: String) {
    self.target = target
    self.value = value
  }

  public var syntax: SyntaxProtocol {
    let left = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(target)))
    let right: ExprSyntax
    if value.hasPrefix("\"") && value.hasSuffix("\"") || value.contains("\\(") {
      right = ExprSyntax(
        StringLiteralExprSyntax(
          openingQuote: .stringQuoteToken(),
          segments: StringLiteralSegmentListSyntax([
            .stringSegment(
              StringSegmentSyntax(content: .stringSegment(String(value.dropFirst().dropLast()))))
          ]),
          closingQuote: .stringQuoteToken()
        ))
    } else {
      right = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(value)))
    }
    let assign = ExprSyntax(
      BinaryOperatorExprSyntax(
        operator: .binaryOperator("+=", leadingTrivia: .space, trailingTrivia: .space)))
    return SequenceExprSyntax(
      elements: ExprListSyntax([
        left,
        assign,
        right,
      ])
    )
  }
}
