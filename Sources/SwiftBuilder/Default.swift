//
//  Default.swift
//  SwiftBuilder
//
//  Created by Leo Dion on 6/15/25.
//
import SwiftSyntax

public struct Default: CodeBlock {
    private let body: [CodeBlock]
    public init(@CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.body = content()
    }
    public var switchCaseSyntax: SwitchCaseSyntax {
        let statements = CodeBlockItemListSyntax(body.compactMap { $0.syntax.as(CodeBlockItemSyntax.self) })
        let label = SwitchDefaultLabelSyntax(
            defaultKeyword: .keyword(.default, trailingTrivia: .space),
            colon: .colonToken()
        )
        return SwitchCaseSyntax(
            label: .default(label),
            statements: statements
        )
    }
    public var syntax: SyntaxProtocol { switchCaseSyntax }
}
