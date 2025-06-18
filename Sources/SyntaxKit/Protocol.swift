//
//  Protocol.swift
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

/// A Swift `protocol` declaration.
public struct Protocol: CodeBlock {
  private let name: String
  private let members: [CodeBlock]
  private var inheritance: [String] = []

  /// Creates a `protocol` declaration.
  /// - Parameters:
  ///   - name: The name of the protocol.
  ///   - content: A ``CodeBlockBuilder`` that provides the members of the protocol.
  public init(_ name: String, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
    self.name = name
    self.members = content()
  }

  /// Sets one or more inherited protocols.
  /// - Parameter types: The list of protocols this protocol inherits from.
  /// - Returns: A copy of the protocol with the inheritance set.
  public func inherits(_ types: String...) -> Self {
    var copy = self
    copy.inheritance = types
    return copy
  }

  public var syntax: SyntaxProtocol {
    let protocolKeyword = TokenSyntax.keyword(.protocol, trailingTrivia: .space)
    let identifier = TokenSyntax.identifier(name)

    // Inheritance clause
    var inheritanceClause: InheritanceClauseSyntax?
    if !inheritance.isEmpty {
      let inheritedTypes = inheritance.map { type in
        InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier(type)))
      }
      inheritanceClause = InheritanceClauseSyntax(
        colon: .colonToken(),
        inheritedTypes: InheritedTypeListSyntax(
          inheritedTypes.enumerated().map { idx, inherited in
            var inheritedType = inherited
            if idx < inheritedTypes.count - 1 {
              inheritedType = inheritedType.with(
                \.trailingComma,
                TokenSyntax.commaToken(trailingTrivia: .space)
              )
            }
            return inheritedType
          }
        )
      )
    }

    // Member block
    let memberBlock = MemberBlockSyntax(
      leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
      members: MemberBlockItemListSyntax(
        members.compactMap { member in
          guard let decl = member.syntax.as(DeclSyntax.self) else { return nil }
          return MemberBlockItemSyntax(decl: decl, trailingTrivia: .newline)
        }
      ),
      rightBrace: .rightBraceToken(leadingTrivia: .newline)
    )

    return ProtocolDeclSyntax(
      protocolKeyword: protocolKeyword,
      name: identifier,
      primaryAssociatedTypeClause: nil,
      inheritanceClause: inheritanceClause,
      genericWhereClause: nil,
      memberBlock: memberBlock
    )
  }
} 