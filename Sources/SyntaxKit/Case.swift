//
//  Case.swift
//  SyntaxKit
//
//  Created by Leo Dion on 6/15/25.
//
import SwiftSyntax

public struct Case: CodeBlock {
    private let patterns: [String]
    private let body: [CodeBlock]
    
    public init(_ patterns: String..., @CodeBlockBuilderResult content: () -> [CodeBlock]) {
        self.patterns = patterns
        self.body = content()
    }
    
    public var switchCaseSyntax: SwitchCaseSyntax {
        let patternList = TuplePatternElementListSyntax(
            patterns.map { TuplePatternElementSyntax(
                label: nil,
                colon: nil,
                pattern: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier($0)))
            )}
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
        let statements = CodeBlockItemListSyntax(body.compactMap { $0.syntax.as(CodeBlockItemSyntax.self) })
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
