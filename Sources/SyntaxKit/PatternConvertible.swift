//
//  PatternConvertible.swift
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

import Foundation
import SwiftSyntax

/// Types that can be turned into a `PatternSyntax` suitable for a `switch` case pattern.
public protocol PatternConvertible {
  /// SwiftSyntax representation of the pattern.
  var patternSyntax: PatternSyntax { get }
}

// MARK: - Literal conformance

extension Literal: PatternConvertible {
  public var patternSyntax: PatternSyntax {
    guard let expr = self.syntax.as(ExprSyntax.self) else {
      fatalError("Literal.syntax did not return ExprSyntax")
    }
    return PatternSyntax(ExpressionPatternSyntax(expression: expr))
  }
}

// MARK: - Int conformance

extension Int: PatternConvertible {
  public var patternSyntax: PatternSyntax {
    let expr = ExprSyntax(IntegerLiteralExprSyntax(digits: .integerLiteral(String(self))))
    return PatternSyntax(ExpressionPatternSyntax(expression: expr))
  }
}

// MARK: - Ranges

extension Swift.Range: PatternConvertible where Bound == Int {
  public var patternSyntax: PatternSyntax {
    let lhs = ExprSyntax(IntegerLiteralExprSyntax(digits: .integerLiteral(String(self.lowerBound))))
    let op = ExprSyntax(BinaryOperatorExprSyntax(operator: .binaryOperator("..<")))
    let rhs = ExprSyntax(IntegerLiteralExprSyntax(digits: .integerLiteral(String(self.upperBound))))
    let seq = SequenceExprSyntax(elements: ExprListSyntax([lhs, op, rhs]))
    return PatternSyntax(ExpressionPatternSyntax(expression: ExprSyntax(seq)))
  }
}

extension Swift.ClosedRange: PatternConvertible where Bound == Int {
  public var patternSyntax: PatternSyntax {
    let lhs = ExprSyntax(IntegerLiteralExprSyntax(digits: .integerLiteral(String(self.lowerBound))))
    let op = ExprSyntax(BinaryOperatorExprSyntax(operator: .binaryOperator("...")))
    let rhs = ExprSyntax(IntegerLiteralExprSyntax(digits: .integerLiteral(String(self.upperBound))))
    let seq = SequenceExprSyntax(elements: ExprListSyntax([lhs, op, rhs]))
    return PatternSyntax(ExpressionPatternSyntax(expression: ExprSyntax(seq)))
  }
}

// MARK: - String identifiers

extension String: PatternConvertible {
  public var patternSyntax: PatternSyntax {
    PatternSyntax(IdentifierPatternSyntax(identifier: .identifier(self)))
  }
}
