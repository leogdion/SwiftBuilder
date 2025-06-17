//
//  VariableExp.swift
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

public struct VariableExp: CodeBlock {
  let name: String

  public init(_ name: String) {
    self.name = name
  }

  public func property(_ propertyName: String) -> CodeBlock {
    PropertyAccessExp(baseName: name, propertyName: propertyName)
  }

  public func call(_ methodName: String) -> CodeBlock {
    FunctionCallExp(baseName: name, methodName: methodName)
  }

  public func call(_ methodName: String, @ParameterExpBuilderResult _ params: () -> [ParameterExp])
    -> CodeBlock
  {
    FunctionCallExp(baseName: name, methodName: methodName, parameters: params())
  }

  public var syntax: SyntaxProtocol {
    TokenSyntax.identifier(name)
  }
}

public struct PropertyAccessExp: CodeBlock {
  let baseName: String
  let propertyName: String

  public init(baseName: String, propertyName: String) {
    self.baseName = baseName
    self.propertyName = propertyName
  }

  public var syntax: SyntaxProtocol {
    let base = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(baseName)))
    let property = TokenSyntax.identifier(propertyName)
    return ExprSyntax(
      MemberAccessExprSyntax(
        base: base,
        dot: .periodToken(),
        name: property
      ))
  }
}

public struct FunctionCallExp: CodeBlock {
  let baseName: String
  let methodName: String
  let parameters: [ParameterExp]

  public init(baseName: String, methodName: String) {
    self.baseName = baseName
    self.methodName = methodName
    self.parameters = []
  }

  public init(baseName: String, methodName: String, parameters: [ParameterExp]) {
    self.baseName = baseName
    self.methodName = methodName
    self.parameters = parameters
  }

  public var syntax: SyntaxProtocol {
    let base = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(baseName)))
    let method = TokenSyntax.identifier(methodName)
    let args = LabeledExprListSyntax(
      parameters.enumerated().map { index, param in
        let expr = param.syntax
        if let labeled = expr as? LabeledExprSyntax {
          var element = labeled
          if index < parameters.count - 1 {
            element = element.with(\.trailingComma, .commaToken(trailingTrivia: .space))
          }
          return element
        } else if let unlabeled = expr as? ExprSyntax {
          return TupleExprElementSyntax(
            label: nil,
            colon: nil,
            expression: unlabeled,
            trailingComma: index < parameters.count - 1 ? .commaToken(trailingTrivia: .space) : nil
          )
        } else {
          fatalError("ParameterExp.syntax must return LabeledExprSyntax or ExprSyntax")
        }
      })
    return ExprSyntax(
      FunctionCallExprSyntax(
        calledExpression: ExprSyntax(
          MemberAccessExprSyntax(
            base: base,
            dot: .periodToken(),
            name: method
          )),
        leftParen: .leftParenToken(),
        arguments: args,
        rightParen: .rightParenToken()
      ))
  }
}
