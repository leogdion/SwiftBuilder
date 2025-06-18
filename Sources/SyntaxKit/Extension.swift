//
//  Extension.swift
//  SyntaxKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import SwiftSyntax

/// A Swift `extension` declaration.
public struct Extension: CodeBlock {
  private let extendedType: String
  private let members: [CodeBlock]
  private var inheritance: [String] = []

  /// Creates an `extension` declaration.
  /// - Parameters:
  ///   - extendedType: The name of the type being extended.
  ///   - content: A ``CodeBlockBuilder`` that provides the members of the extension.
  public init(_ extendedType: String, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
    self.extendedType = extendedType
    self.members = content()
  }

  /// Sets the inheritance for the extension.
  /// - Parameter types: The types to inherit from.
  /// - Returns: A copy of the extension with the inheritance set.
  public func inherits(_ types: String...) -> Self {
    var copy = self
    copy.inheritance = types
    return copy
  }

  public var syntax: SyntaxProtocol {
    let extensionKeyword = TokenSyntax.keyword(.extension, trailingTrivia: .space)
    let identifier = TokenSyntax.identifier(extendedType, trailingTrivia: .space)

    var inheritanceClause: InheritanceClauseSyntax?
    if !inheritance.isEmpty {
      let inheritedTypes = inheritance.map { type in
        InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier(type)))
      }
      inheritanceClause = InheritanceClauseSyntax(
        colon: .colonToken(),
        inheritedTypes: InheritedTypeListSyntax(
          inheritedTypes.enumerated().map { idx, inherited in
            var type = inherited
            if idx < inheritedTypes.count - 1 {
              type = type.with(\.trailingComma, TokenSyntax.commaToken(trailingTrivia: .space))
            }
            return type
          }
        )
      )
    }

    let memberBlock = MemberBlockSyntax(
      leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
      members: MemberBlockItemListSyntax(
        members.compactMap { member in
          guard let syntax = member.syntax.as(DeclSyntax.self) else { return nil }
          return MemberBlockItemSyntax(decl: syntax, trailingTrivia: .newline)
        }),
      rightBrace: .rightBraceToken(leadingTrivia: .newline)
    )

    return ExtensionDeclSyntax(
      extensionKeyword: extensionKeyword,
      extendedType: IdentifierTypeSyntax(name: identifier),
      inheritanceClause: inheritanceClause,
      memberBlock: memberBlock
    )
  }
} 