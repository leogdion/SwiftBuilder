//
//  Enum.swift
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

/// A Swift `enum` declaration.
public struct Enum: CodeBlock {
  private let name: String
  private let members: [CodeBlock]
  private var inheritance: String?
  private var attributes: [AttributeInfo] = []

  /// Creates an `enum` declaration.
  /// - Parameters:
  ///   - name: The name of the enum.
  ///   - content: A ``CodeBlockBuilder`` that provides the members of the enum.
  public init(_ name: String, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
    self.name = name
    self.members = content()
  }

  /// Sets the inheritance for the enum.
  /// - Parameter type: The type to inherit from.
  /// - Returns: A copy of the enum with the inheritance set.
  public func inherits(_ type: String) -> Self {
    var copy = self
    copy.inheritance = type
    return copy
  }

  /// Adds an attribute to the enum declaration.
  /// - Parameters:
  ///   - attribute: The attribute name (without the @ symbol).
  ///   - arguments: The arguments for the attribute, if any.
  /// - Returns: A copy of the enum with the attribute added.
  public func attribute(_ attribute: String, arguments: [String] = []) -> Self {
    var copy = self
    copy.attributes.append(AttributeInfo(name: attribute, arguments: arguments))
    return copy
  }

  public var syntax: SyntaxProtocol {
    let enumKeyword = TokenSyntax.keyword(.enum, trailingTrivia: .space)
    let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)

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

    return EnumDeclSyntax(
      attributes: buildAttributeList(from: attributes),
      enumKeyword: enumKeyword,
      name: identifier,
      inheritanceClause: inheritanceClause,
      memberBlock: memberBlock
    )
  }

  private func buildAttributeList(from attributes: [AttributeInfo]) -> AttributeListSyntax {
    if attributes.isEmpty {
      return AttributeListSyntax([])
    }
    let attributeElements = attributes.map { attributeInfo in
      let arguments = attributeInfo.arguments

      var leftParen: TokenSyntax?
      var rightParen: TokenSyntax?
      var argumentsSyntax: AttributeSyntax.Arguments?

      if !arguments.isEmpty {
        leftParen = .leftParenToken()
        rightParen = .rightParenToken()

        let argumentList = arguments.map { argument in
          DeclReferenceExprSyntax(baseName: .identifier(argument))
        }

        argumentsSyntax = .argumentList(
          LabeledExprListSyntax(
            argumentList.enumerated().map { index, expr in
              var element = LabeledExprSyntax(expression: ExprSyntax(expr))
              if index < argumentList.count - 1 {
                element = element.with(\.trailingComma, .commaToken(trailingTrivia: .space))
              }
              return element
            }
          )
        )
      }

      return AttributeListSyntax.Element(
        AttributeSyntax(
          atSign: .atSignToken(),
          attributeName: IdentifierTypeSyntax(name: .identifier(attributeInfo.name)),
          leftParen: leftParen,
          arguments: argumentsSyntax,
          rightParen: rightParen
        )
      )
    }
    return AttributeListSyntax(attributeElements)
  }
}

/// A Swift `case` declaration inside an `enum`.
public struct EnumCase: CodeBlock {
  private let name: String
  private var value: String?
  private var intValue: Int?

  /// Creates a `case` declaration.
  /// - Parameter name: The name of the case.
  public init(_ name: String) {
    self.name = name
  }

  /// Sets the raw value of the case to a string.
  /// - Parameter value: The string value.
  /// - Returns: A copy of the case with the raw value set.
  public func equals(_ value: String) -> Self {
    var copy = self
    copy.value = value
    copy.intValue = nil
    return copy
  }

  /// Sets the raw value of the case to an integer.
  /// - Parameter value: The integer value.
  /// - Returns: A copy of the case with the raw value set.
  public func equals(_ value: Int) -> Self {
    var copy = self
    copy.value = nil
    copy.intValue = value
    return copy
  }

  public var syntax: SyntaxProtocol {
    let caseKeyword = TokenSyntax.keyword(.case, trailingTrivia: .space)
    let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)

    var initializer: InitializerClauseSyntax?
    if let value = value {
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
    } else if let intValue = intValue {
      initializer = InitializerClauseSyntax(
        equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
        value: IntegerLiteralExprSyntax(digits: .integerLiteral(String(intValue)))
      )
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
