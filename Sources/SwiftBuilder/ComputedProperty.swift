import SwiftSyntax

public struct ComputedProperty: CodeBlock {
    private let name: String
    private let type: String
    private let body: [CodeBlock]
    
    public init(_ name: String, type: String, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.name = name
        self.type = type
        self.body = content()
    }
    
    public var syntax: SyntaxProtocol {
        let statements = CodeBlockItemListSyntax(self.body.compactMap { item in
            if let cb = item.syntax as? CodeBlockItemSyntax { return cb.with(\.trailingTrivia, .newline) }
            if let stmt = item.syntax as? StmtSyntax {
                return CodeBlockItemSyntax(item: .stmt(stmt), trailingTrivia: .newline)
            }
            if let expr = item.syntax as? ExprSyntax {
                return CodeBlockItemSyntax(item: .expr(expr), trailingTrivia: .newline)
            }
            return nil
        })
        let accessor = AccessorBlockSyntax(
            leftBrace: TokenSyntax.leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
            accessors: .getter(statements),
            rightBrace: TokenSyntax.rightBraceToken(leadingTrivia: .newline)
        )
        let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
        let typeAnnotation = TypeAnnotationSyntax(
            colon: TokenSyntax.colonToken(leadingTrivia: .space, trailingTrivia: .space),
            type: IdentifierTypeSyntax(name: .identifier(type))
        )
        return VariableDeclSyntax(
            bindingSpecifier: TokenSyntax.keyword(.var, trailingTrivia: .space),
            bindings: PatternBindingListSyntax([
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: identifier),
                    typeAnnotation: typeAnnotation,
                    accessorBlock: accessor
                )
            ])
        )
    }
} 