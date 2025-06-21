//
//  Catch.swift
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

/// A Swift `catch` clause.
public struct Catch: CodeBlock {
  private let pattern: CodeBlock?
  private let body: [CodeBlock]

  /// Creates a `catch` clause with a pattern.
  /// - Parameters:
  ///   - pattern: The pattern to match for this catch clause.
  ///   - content: A ``CodeBlockBuilder`` that provides the body of the catch clause.
  public init(
    _ pattern: CodeBlock,
    @CodeBlockBuilderResult _ content: () -> [CodeBlock]
  ) {
    self.pattern = pattern
    self.body = content()
  }

  /// Creates a `catch` clause without a pattern (catches all errors).
  /// - Parameter content: A ``CodeBlockBuilder`` that provides the body of the catch clause.
  public init(@CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
    self.pattern = nil
    self.body = content()
  }

  /// Creates a `catch` clause for a specific enum case.
  /// - Parameters:
  ///   - enumCase: The enum case to catch.
  ///   - content: A ``CodeBlockBuilder`` that provides the body of the catch clause.
  public static func `catch`(
    _ enumCase: EnumCase,
    @CodeBlockBuilderResult _ content: () -> [CodeBlock]
  ) -> Catch {
    Catch(enumCase, content)
  }

  public var catchClauseSyntax: CatchClauseSyntax {
    // Build catch items (patterns)
    var catchItems: CatchItemListSyntax?
    if let pattern = pattern {
      let patternSyntax: PatternSyntax
      
      if let enumCase = pattern as? EnumCase {
        if let associated = enumCase.caseAssociatedValue {
          // Handle EnumCase with associated value
          // Split the case name into type and case if needed
          let baseName = enumCase.caseName
          let baseParts = baseName.split(separator: ".")
          let (typeName, caseName) = baseParts.count == 2 ? (String(baseParts[0]), String(baseParts[1])) : ("", baseName)
          // Build the pattern: Type.caseName(let associatedName)
          let memberAccess = MemberAccessExprSyntax(
            base: typeName.isEmpty ? nil : ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(typeName))),
            dot: .periodToken(),
            name: .identifier(caseName)
          )
          // Build the tuple pattern: (let coinsNeeded)
          let tuplePattern = TuplePatternSyntax(
            leftParen: .leftParenToken(),
            elements: TuplePatternElementListSyntax([
              TuplePatternElementSyntax(
                pattern: PatternSyntax(
                  ValueBindingPatternSyntax(
                    bindingSpecifier: .keyword(.let, trailingTrivia: .space),
                    pattern: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier(associated.name)))
                  )
                ),
                trailingComma: nil
              )
            ]),
            rightParen: .rightParenToken()
          )
          // Build the full pattern: EnumType.caseName(let coinsNeeded)
          let enumPattern = ExpressionPatternSyntax(
            expression: ExprSyntax(
              MemberAccessExprSyntax(
                base: typeName.isEmpty ? nil : ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(typeName))),
                dot: .periodToken(),
                name: .identifier(caseName)
              )
            )
          )
          // Combine the enum pattern and tuple pattern
          let patternWithAssociated = PatternSyntax(
            TuplePatternSyntax(
              leftParen: .leftParenToken(),
              elements: TuplePatternElementListSyntax([
                TuplePatternElementSyntax(
                  pattern: PatternSyntax(
                    ValueBindingPatternSyntax(
                      bindingSpecifier: .keyword(.let, trailingTrivia: .space),
                      pattern: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier(associated.name)))
                    )
                  ),
                  trailingComma: nil
                )
              ]),
              rightParen: .rightParenToken()
            )
          )
          // Use a pattern that matches 'caseName(let coinsNeeded)'
          patternSyntax = PatternSyntax(
            ExpressionPatternSyntax(
              expression: ExprSyntax(
                FunctionCallExprSyntax(
                  calledExpression: ExprSyntax(memberAccess),
                  leftParen: .leftParenToken(),
                  arguments: LabeledExprListSyntax([
                    LabeledExprSyntax(
                      label: nil,
                      colon: nil,
                      expression: ExprSyntax(
                        PatternExprSyntax(
                          pattern: PatternSyntax(
                            ValueBindingPatternSyntax(
                              bindingSpecifier: .keyword(.let, trailingTrivia: .space),
                              pattern: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier(associated.name)))
                            )
                          )
                        )
                      ),
                      trailingComma: nil
                    )
                  ]),
                  rightParen: .rightParenToken()
                )
              )
            )
          )
        } else {
          // Handle EnumCase patterns without associated value
          let enumCaseExpr = ExprSyntax(
            DeclReferenceExprSyntax(baseName: .identifier(enumCase.caseName))
          )
          patternSyntax = PatternSyntax(ExpressionPatternSyntax(expression: enumCaseExpr))
        }
      } else {
        // Handle other patterns
        patternSyntax = PatternSyntax(
          ExpressionPatternSyntax(
            expression: ExprSyntax(
              fromProtocol: pattern.syntax.as(ExprSyntax.self)
                ?? DeclReferenceExprSyntax(baseName: .identifier(""))
            )
          )
        )
      }
      
      catchItems = CatchItemListSyntax([
        CatchItemSyntax(pattern: patternSyntax)
      ])
    }

    // Build catch body
    let catchBody = CodeBlockSyntax(
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
      rightBrace: .rightBraceToken(leadingTrivia: .newline, trailingTrivia: .space)
    )

    return CatchClauseSyntax(
      catchKeyword: .keyword(.catch, trailingTrivia: .space),
      catchItems: catchItems ?? CatchItemListSyntax([]),
      body: catchBody
    )
  }

  public var syntax: SyntaxProtocol {
    catchClauseSyntax
  }
} 