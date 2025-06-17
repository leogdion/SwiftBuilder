//
//  Struct.swift
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

public struct Struct: CodeBlock {
  private let name: String
  private let members: [CodeBlock]
  private var inheritance: String?
  private var genericParameter: String?

  public init(
    _ name: String, generic: String? = nil, @CodeBlockBuilderResult _ content: () -> [CodeBlock]
  ) {
    self.name = name
    self.members = content()
    self.genericParameter = generic
  }

  public func inherits(_ type: String) -> Self {
    var copy = self
    copy.inheritance = type
    return copy
  }

  public var syntax: SyntaxProtocol {
    let structKeyword = TokenSyntax.keyword(.struct, trailingTrivia: .space)
    let identifier = TokenSyntax.identifier(name)

    var genericParameterClause: GenericParameterClauseSyntax?
    if let generic = genericParameter {
      let genericParameter = GenericParameterSyntax(
        name: .identifier(generic),
        trailingComma: nil
      )
      genericParameterClause = GenericParameterClauseSyntax(
        leftAngle: .leftAngleToken(),
        parameters: GenericParameterListSyntax([genericParameter]),
        rightAngle: .rightAngleToken()
      )
    }

    var inheritanceClause: InheritanceClauseSyntax?
    if let inheritance = inheritance {
      let inheritedType = InheritedTypeSyntax(
        type: IdentifierTypeSyntax(name: .identifier(inheritance)))
      inheritanceClause = InheritanceClauseSyntax(
        colon: .colonToken(), inheritedTypes: InheritedTypeListSyntax([inheritedType]))
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

    return StructDeclSyntax(
      structKeyword: structKeyword,
      name: identifier,
      genericParameterClause: genericParameterClause,
      inheritanceClause: inheritanceClause,
      memberBlock: memberBlock
    )
  }
}
