//
//  DictionaryValue.swift
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

/// A protocol for types that can be used as dictionary keys or values.
/// This includes both Literal types and CodeBlock types that can be converted to expressions.
public protocol DictionaryValue {
  /// The SwiftSyntax expression representation of this value.
  var exprSyntax: ExprSyntax { get }
}

// MARK: - Literal Conformance

extension Literal: DictionaryValue {
  // Literal already has exprSyntax from ExprCodeBlock protocol
}

// MARK: - CodeBlock Conformance

extension CodeBlock where Self: DictionaryValue {
  public var exprSyntax: ExprSyntax {
    if let expr = self.syntax.as(ExprSyntax.self) {
      return expr
    }

    if let token = self.syntax.as(TokenSyntax.self) {
      return ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(token.text)))
    }

    fatalError("CodeBlock of type \(type(of: self.syntax)) cannot be represented as ExprSyntax")
  }
}

// MARK: - Specific CodeBlock Types

extension Call: DictionaryValue {}
extension Init: DictionaryValue {}
extension VariableExp: DictionaryValue {}
extension PropertyAccessExp: DictionaryValue {}
extension FunctionCallExp: DictionaryValue {}
extension Infix: DictionaryValue {}
