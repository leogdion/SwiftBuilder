import SwiftSyntax

public struct Group: CodeBlock {
    let members: [CodeBlock]

    public init(@CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.members = content()
    }

    public var syntax: SyntaxProtocol {
        let statements = members.flatMap { block -> [CodeBlockItemSyntax] in
            if let list = block.syntax.as(CodeBlockItemListSyntax.self) {
                return Array(list)
            }

            let item: CodeBlockItemSyntax.Item
            if let decl = block.syntax.as(DeclSyntax.self) {
                item = .decl(decl)
            } else if let stmt = block.syntax.as(StmtSyntax.self) {
                item = .stmt(stmt)
            } else if let expr = block.syntax.as(ExprSyntax.self) {
                item = .expr(expr)
            } else {
                fatalError("Unsupported syntax type in group: \(type(of: block.syntax)) from \(block)")
            }
            return [CodeBlockItemSyntax(item: item, trailingTrivia: .newline)]
        }
        return CodeBlockItemListSyntax(statements)
    }
} 