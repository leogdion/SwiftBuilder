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
        let statements = CodeBlockItemListSyntax(body.compactMap {
            var item: CodeBlockItemSyntax?
            if let decl = $0.syntax.as(DeclSyntax.self) {
                item = CodeBlockItemSyntax(item: .decl(decl))
            } else if let expr = $0.syntax.as(ExprSyntax.self) {
                item = CodeBlockItemSyntax(item: .expr(expr))
            } else if let stmt = $0.syntax.as(StmtSyntax.self) {
                item = CodeBlockItemSyntax(item: .stmt(stmt))
            }
            return item?.with(\.trailingTrivia, .newline)
        })
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
