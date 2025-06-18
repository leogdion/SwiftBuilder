//
//  TypeAlias.swift
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

/// A Swift `typealias` declaration.
public struct TypeAlias: CodeBlock {
  private let name: String
  private let existingType: String

  /// Creates a `typealias` declaration.
  /// - Parameters:
  ///   - name: The new name that will alias the existing type.
  ///   - type: The existing type that is being aliased.
  public init(_ name: String, equals type: String) {
    self.name = name
    self.existingType = type
  }

  public var syntax: SyntaxProtocol {
    // `typealias` keyword token
    let keyword = TokenSyntax.keyword(.typealias, trailingTrivia: .space)

    // Alias identifier
    let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)

    // Initializer clause – `= ExistingType`
    let initializer = TypeInitializerClauseSyntax(
      equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
      value: IdentifierTypeSyntax(name: .identifier(existingType))
    )

    return TypeAliasDeclSyntax(
      typealiasKeyword: keyword,
      name: identifier,
      initializer: initializer
    )
  }
}
