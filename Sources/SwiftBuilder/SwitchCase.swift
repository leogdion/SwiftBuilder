//
//  SwitchCase.swift
//  SwiftBuilder
//
//  Created by Leo Dion on 6/15/25.
//
import SwiftSyntax

public struct SwitchCase: CodeBlock {
    private let patterns: [String]
    private let body: [CodeBlock]
    
    public init(_ patterns: String..., @CodeBlockBuilderResult content: () -> [CodeBlock]) {
        self.patterns = patterns
        self.body = content()
    }
    
    public var switchCaseSyntax: SwitchCaseSyntax {
        let caseItems = SwitchCaseItemListSyntax(patterns.enumerated().map { index, pattern in
            var item = SwitchCaseItemSyntax(
                pattern: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier(pattern)))
            )
            if index < patterns.count - 1 {
                item = item.with(\.trailingComma, .commaToken(trailingTrivia: .space))
            }
            return item
        })
        let statements = CodeBlockItemListSyntax(body.compactMap { $0.syntax.as(CodeBlockItemSyntax.self) })
        let label = SwitchCaseLabelSyntax(
            caseKeyword: .keyword(.case, trailingTrivia: .space),
            caseItems: caseItems,
            colon: .colonToken(trailingTrivia: .newline)
        )
        return SwitchCaseSyntax(
            label: .case(label),
            statements: statements
        )
    }
    
    public var syntax: SyntaxProtocol { switchCaseSyntax }
}
