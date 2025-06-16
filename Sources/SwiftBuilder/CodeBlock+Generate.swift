import Foundation
import SwiftSyntax

public extension CodeBlock {
    func generateCode() -> String {
        let statements: CodeBlockItemListSyntax
        if let list = self.syntax.as(CodeBlockItemListSyntax.self) {
            statements = list
        } else {
            let item: CodeBlockItemSyntax.Item
            if let decl = self.syntax.as(DeclSyntax.self) {
                item = .decl(decl)
            } else if let stmt = self.syntax.as(StmtSyntax.self) {
                item = .stmt(stmt)
            } else if let expr = self.syntax.as(ExprSyntax.self) {
                item = .expr(expr)
            } else {
                fatalError("Unsupported syntax type at top level: \(type(of: self.syntax)) generating from \(self)")
            }
            statements = CodeBlockItemListSyntax([CodeBlockItemSyntax(item: item, trailingTrivia: .newline)])
        }
        
        let sourceFile = SourceFileSyntax(statements: statements)
        return sourceFile.description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
} 