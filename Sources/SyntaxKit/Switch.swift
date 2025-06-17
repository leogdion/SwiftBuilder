//
//  Switch.swift
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

public struct Switch: CodeBlock {
  private let expression: String
  private let cases: [CodeBlock]

  public init(_ expression: String, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
    self.expression = expression
    self.cases = content()
  }

  public var syntax: SyntaxProtocol {
    let expr = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(expression)))
    let casesArr: [SwitchCaseSyntax] = self.cases.compactMap {
      if let switchCase = $0 as? SwitchCase { return switchCase.switchCaseSyntax }
      if let switchDefault = $0 as? Default { return switchDefault.switchCaseSyntax }
      return nil
    }
    let cases = SwitchCaseListSyntax(casesArr.map { SwitchCaseListSyntax.Element($0) })
    let switchExpr = SwitchExprSyntax(
      switchKeyword: .keyword(.switch, trailingTrivia: .space),
      subject: expr,
      leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
      cases: cases,
      rightBrace: .rightBraceToken(leadingTrivia: .newline)
    )
    return switchExpr
  }
}
