//
//  Parameter.swift
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
import SwiftParser
import SwiftSyntax

/// A parameter for a function or initializer.
public struct Parameter: CodeBlock {
  let name: String
  let type: String
  let defaultValue: String?
  let isUnnamed: Bool
  internal var attributes: [AttributeInfo] = []

  /// Creates a parameter for a function or initializer.
  /// - Parameters:
  ///   - name: The name of the parameter.
  ///   - type: The type of the parameter.
  ///   - defaultValue: The default value of the parameter, if any.
  ///   - isUnnamed: A Boolean value that indicates whether the parameter is unnamed.
  public init(name: String, type: String, defaultValue: String? = nil, isUnnamed: Bool = false) {
    self.name = name
    self.type = type
    self.defaultValue = defaultValue
    self.isUnnamed = isUnnamed
  }

  /// Adds an attribute to the parameter declaration.
  /// - Parameters:
  ///   - attribute: The attribute name (without the @ symbol).
  ///   - arguments: The arguments for the attribute, if any.
  /// - Returns: A copy of the parameter with the attribute added.
  public func attribute(_ attribute: String, arguments: [String] = []) -> Self {
    var copy = self
    copy.attributes.append(AttributeInfo(name: attribute, arguments: arguments))
    return copy
  }

  public var syntax: SyntaxProtocol {
    // Not used for function signature, but for call sites (Init, etc.)
    if let defaultValue = defaultValue {
      return LabeledExprSyntax(
        label: .identifier(name),
        colon: .colonToken(),
        expression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(defaultValue)))
      )
    } else {
      return LabeledExprSyntax(
        label: .identifier(name),
        colon: .colonToken(),
        expression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(name)))
      )
    }
    // Note: If you want to support attributes in parameter syntax, you would need to update the function signature generation in Function.swift to use these attributes.
  }
}
