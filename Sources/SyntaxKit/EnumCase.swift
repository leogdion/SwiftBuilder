//
//  EnumCase.swift
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

/// A Swift `case` declaration inside an `enum`.
public struct EnumCase: CodeBlock {
  private let name: String
  private var literalValue: Literal?

  /// Creates a `case` declaration.
  /// - Parameter name: The name of the case.
  public init(_ name: String) {
    self.name = name
    self.literalValue = nil
  }

  /// Sets the raw value of the case to a Literal.
  /// - Parameter value: The literal value.
  /// - Returns: A copy of the case with the raw value set.
  public func equals(_ value: Literal) -> Self {
    var copy = self
    copy.literalValue = value
    return copy
  }

  /// Sets the raw value of the case to a string (for backward compatibility).
  /// - Parameter value: The string value.
  /// - Returns: A copy of the case with the raw value set.
  public func equals(_ value: String) -> Self {
    self.equals(.string(value))
  }

  /// Sets the raw value of the case to an integer (for backward compatibility).
  /// - Parameter value: The integer value.
  /// - Returns: A copy of the case with the raw value set.
  public func equals(_ value: Int) -> Self {
    self.equals(.integer(value))
  }

  /// Sets the raw value of the case to a float (for backward compatibility).
  /// - Parameter value: The float value.
  /// - Returns: A copy of the case with the raw value set.
  public func equals(_ value: Double) -> Self {
    self.equals(.float(value))
  }

  public var syntax: SyntaxProtocol {
    let caseKeyword = TokenSyntax.keyword(.case, trailingTrivia: .space)
    let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)

    var initializer: InitializerClauseSyntax?
    if let literal = literalValue {
      switch literal {
      case .string(let value):
        initializer = InitializerClauseSyntax(
          equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
          value: StringLiteralExprSyntax(
            openingQuote: .stringQuoteToken(),
            segments: StringLiteralSegmentListSyntax([
              .stringSegment(StringSegmentSyntax(content: .stringSegment(value)))
            ]),
            closingQuote: .stringQuoteToken()
          )
        )
      case .float(let value):
        initializer = InitializerClauseSyntax(
          equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
          value: FloatLiteralExprSyntax(literal: .floatLiteral(String(value)))
        )
      case .integer(let value):
        initializer = InitializerClauseSyntax(
          equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
          value: IntegerLiteralExprSyntax(digits: .integerLiteral(String(value)))
        )
      case .nil:
        initializer = InitializerClauseSyntax(
          equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
          value: NilLiteralExprSyntax(nilKeyword: .keyword(.nil))
        )
      case .boolean(let value):
        initializer = InitializerClauseSyntax(
          equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
          value: BooleanLiteralExprSyntax(literal: value ? .keyword(.true) : .keyword(.false))
        )
      case .ref(let value):
        initializer = InitializerClauseSyntax(
          equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
          value: DeclReferenceExprSyntax(baseName: .identifier(value))
        )
      case .tuple:
        fatalError("Tuple is not supported as a raw value for enum cases.")
      case .array:
        fatalError("Array is not supported as a raw value for enum cases.")
      case .dictionary:
        fatalError("Dictionary is not supported as a raw value for enum cases.")
      }
    }

    return EnumCaseDeclSyntax(
      caseKeyword: caseKeyword,
      elements: EnumCaseElementListSyntax([
        EnumCaseElementSyntax(
          leadingTrivia: .space,
          _: nil,
          name: identifier,
          _: nil,
          parameterClause: nil,
          _: nil,
          rawValue: initializer,
          _: nil,
          trailingComma: nil,
          trailingTrivia: .newline
        )
      ])
    )
  }
} 