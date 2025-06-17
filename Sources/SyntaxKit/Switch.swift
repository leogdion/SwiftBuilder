//
//  Switch.swift
//  SyntaxKit
//
//  Created by Leo Dion on 6/15/25.
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
            if let c = $0 as? SwitchCase { return c.switchCaseSyntax }
            if let d = $0 as? Default { return d.switchCaseSyntax }
            return nil
        }
        let cases = SwitchCaseListSyntax(casesArr.map { SwitchCaseListSyntax.Element.init($0) })
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
