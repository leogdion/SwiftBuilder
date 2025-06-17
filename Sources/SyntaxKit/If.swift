//
//  If.swift
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

/// An `if` statement.
public struct If: CodeBlock {
  private let condition: CodeBlock
  private let body: [CodeBlock]
  private let elseBody: [CodeBlock]?

  /// Creates an `if` statement.
  /// - Parameters:
  ///   - condition: The condition to evaluate. This can be a ``Let`` for optional binding.
  ///   - then: A ``CodeBlockBuilder`` that provides the body of the `if` block.
  ///   - elseBody: A ``CodeBlockBuilder`` that provides the body of the `else` block, if any.
  public init(
    _ condition: CodeBlock, @CodeBlockBuilderResult then: () -> [CodeBlock],
    else elseBody: (() -> [CodeBlock])? = nil
  ) {
    self.condition = condition
    self.body = then()
    self.elseBody = elseBody?()
  }

  public var syntax: SyntaxProtocol {
    let cond: ConditionElementSyntax
    if let letCond = condition as? Let {
      cond = ConditionElementSyntax(
        condition: .optionalBinding(
          OptionalBindingConditionSyntax(
            bindingSpecifier: .keyword(.let, trailingTrivia: .space),
            pattern: IdentifierPatternSyntax(identifier: .identifier(letCond.name)),
            initializer: InitializerClauseSyntax(
              equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
              value: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(letCond.value)))
            )
          )
        )
      )
    } else {
      cond = ConditionElementSyntax(
        condition: .expression(
          ExprSyntax(
            fromProtocol: condition.syntax.as(ExprSyntax.self)
              ?? DeclReferenceExprSyntax(baseName: .identifier(""))))
      )
    }
    let bodyBlock = CodeBlockSyntax(
      leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
      statements: CodeBlockItemListSyntax(
        body.compactMap {
          var item: CodeBlockItemSyntax?
          if let decl = $0.syntax.as(DeclSyntax.self) {
            item = CodeBlockItemSyntax(item: .decl(decl))
          } else if let expr = $0.syntax.as(ExprSyntax.self) {
            item = CodeBlockItemSyntax(item: .expr(expr))
          } else if let stmt = $0.syntax.as(StmtSyntax.self) {
            item = CodeBlockItemSyntax(item: .stmt(stmt))
          }
          return item?.with(\.trailingTrivia, .newline)
        }),
      rightBrace: .rightBraceToken(leadingTrivia: .newline)
    )
    let elseBlock = elseBody.map {
      IfExprSyntax.ElseBody(
        CodeBlockSyntax(
          leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
          statements: CodeBlockItemListSyntax(
            $0.compactMap {
              var item: CodeBlockItemSyntax?
              if let decl = $0.syntax.as(DeclSyntax.self) {
                item = CodeBlockItemSyntax(item: .decl(decl))
              } else if let expr = $0.syntax.as(ExprSyntax.self) {
                item = CodeBlockItemSyntax(item: .expr(expr))
              } else if let stmt = $0.syntax.as(StmtSyntax.self) {
                item = CodeBlockItemSyntax(item: .stmt(stmt))
              }
              return item?.with(\.trailingTrivia, .newline)
            }),
          rightBrace: .rightBraceToken(leadingTrivia: .newline)
        ))
    }
    return ExprSyntax(
      IfExprSyntax(
        ifKeyword: .keyword(.if, trailingTrivia: .space),
        conditions: ConditionElementListSyntax([cond]),
        body: bodyBlock,
        elseKeyword: elseBlock != nil ? .keyword(.else, trailingTrivia: .space) : nil,
        elseBody: elseBlock
      )
    )
  }
}
