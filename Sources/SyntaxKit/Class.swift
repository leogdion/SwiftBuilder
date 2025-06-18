//
//  Class.swift
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

/// A Swift `class` declaration.
public struct Class: CodeBlock {
  private let name: String
  private let members: [CodeBlock]
  private var inheritance: [String] = []
  private var genericParameters: [String] = []
  private var isFinal: Bool = false

  /// Creates a `class` declaration.
  /// - Parameters:
  ///   - name: The name of the class.
  ///   - generics: A list of generic parameters for the class.
  ///   - content: A ``CodeBlockBuilder`` that provides the members of the class.
  public init(
    _ name: String,
    generics: [String] = [],
    @CodeBlockBuilderResult _ content: () -> [CodeBlock]
  ) {
    self.name = name
    self.members = content()
    self.genericParameters = generics
  }

  /// Sets one or more inherited types (superclass first followed by any protocols).
  /// - Parameter types: The list of types to inherit from.
  /// - Returns: A copy of the class with the inheritance set.
  public func inherits(_ types: String...) -> Self {
    var copy = self
    copy.inheritance = types
    return copy
  }

  /// Marks the class declaration as `final`.
  /// - Returns: A copy of the class marked as `final`.
  public func final() -> Self {
    var copy = self
    copy.isFinal = true
    return copy
  }

  public var syntax: SyntaxProtocol {
    let classKeyword = TokenSyntax.keyword(.class, trailingTrivia: .space)
    let identifier = TokenSyntax.identifier(name)

    // Generic parameter clause
    var genericParameterClause: GenericParameterClauseSyntax?
    if !genericParameters.isEmpty {
      let parameterList = GenericParameterListSyntax(
        genericParameters.enumerated().map { idx, name in
          var param = GenericParameterSyntax(name: .identifier(name))
          if idx < genericParameters.count - 1 {
            param = param.with(
              \.trailingComma,
              TokenSyntax.commaToken(trailingTrivia: .space)
            )
          }
          return param
        }
      )
      genericParameterClause = GenericParameterClauseSyntax(
        leftAngle: .leftAngleToken(),
        parameters: parameterList,
        rightAngle: .rightAngleToken()
      )
    }

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

    // Modifiers
    var modifiers: DeclModifierListSyntax = []
    if isFinal {
      modifiers = DeclModifierListSyntax([
        DeclModifierSyntax(name: .keyword(.final, trailingTrivia: .space))
      ])
    }

    return ClassDeclSyntax(
      modifiers: modifiers,
      classKeyword: classKeyword,
      name: identifier,
      genericParameterClause: genericParameterClause,
      inheritanceClause: inheritanceClause,
      memberBlock: memberBlock
    )
  }
}
