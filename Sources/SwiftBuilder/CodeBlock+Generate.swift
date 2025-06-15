import Foundation
import SwiftSyntax

public extension CodeBlock {
    func generateCode() -> String {
        guard let decl = syntax as? DeclSyntaxProtocol else {
            fatalError("Only declaration syntax is supported at the top level.")
        }
        let sourceFile = SourceFileSyntax(
            statements: CodeBlockItemListSyntax([
                CodeBlockItemSyntax(item: .decl(DeclSyntax(decl)))
            ])
        )
      return sourceFile.description
    }
}

public extension Array where Element == CodeBlock {
    func generateCode() -> String {
        let decls = compactMap { $0.syntax as? DeclSyntaxProtocol }
        let sourceFile = SourceFileSyntax(
            statements: CodeBlockItemListSyntax(decls.map { decl in
                CodeBlockItemSyntax(item: .decl(DeclSyntax(decl)))
            })
        )
        return sourceFile.description
    }
} 