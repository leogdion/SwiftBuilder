//
//  Case.swift
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

/// A `case` in a `switch` statement with tuple-style patterns.
public struct Case: CodeBlock {
  private let patterns: [String]
  private let body: [CodeBlock]

  /// Creates a `case` for a `switch` statement.
  /// - Parameters:
  ///   - patterns: The patterns to match for the case.
  ///   - content: A ``CodeBlockBuilder`` that provides the body of the case.
  public init(_ patterns: String..., @CodeBlockBuilderResult content: () -> [CodeBlock]) {
    self.patterns = patterns
    self.body = content()
  }

  public var switchCaseSyntax: SwitchCaseSyntax {
    let patternList = TuplePatternElementListSyntax(
      patterns.map {
        TuplePatternElementSyntax(
          label: nil,
          colon: nil,
          pattern: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier($0)))
        )
      }
    )
    let caseItems = SwitchCaseItemListSyntax([
      SwitchCaseItemSyntax(
        pattern: TuplePatternSyntax(
          leftParen: .leftParenToken(),
          elements: patternList,
          rightParen: .rightParenToken()
        )
      )
    ])
    let statements = CodeBlockItemListSyntax(
      body.compactMap { $0.syntax.as(CodeBlockItemSyntax.self) })
    let label = SwitchCaseLabelSyntax(
      caseKeyword: .keyword(.case, trailingTrivia: .space),
      caseItems: caseItems,
      colon: .colonToken()
    )
    return SwitchCaseSyntax(
      label: .case(label),
      statements: statements
    )
  }

  public var syntax: SyntaxProtocol { switchCaseSyntax }
}
