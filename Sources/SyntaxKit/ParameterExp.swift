//
//  ParameterExp.swift
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

/// A parameter for a function call.
public struct ParameterExp: CodeBlock {
  internal let name: String
  internal let value: String

  /// Creates a parameter for a function call.
  /// - Parameters:
  ///   - name: The name of the parameter.
  ///   - value: The value of the parameter.
  public init(name: String, value: String) {
    self.name = name
    self.value = value
  }

  public var syntax: SyntaxProtocol {
    if name.isEmpty {
      return ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(value)))
    } else {
      return LabeledExprSyntax(
        label: .identifier(name),
        colon: .colonToken(),
        expression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(value)))
      )
    }
  }
}
