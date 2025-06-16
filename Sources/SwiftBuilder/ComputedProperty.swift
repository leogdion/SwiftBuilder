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
        let accessor = AccessorBlockSyntax(
            leftBrace: TokenSyntax.leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
            accessors: .getter(CodeBlockItemListSyntax(body.compactMap {
                var item: CodeBlockItemSyntax?
                if let decl = $0.syntax.as(DeclSyntax.self) {
                    item = CodeBlockItemSyntax(item: .decl(decl))
                } else if let expr = $0.syntax.as(ExprSyntax.self) {
                    item = CodeBlockItemSyntax(item: .expr(expr))
                } else if let stmt = $0.syntax.as(StmtSyntax.self) {
                    item = CodeBlockItemSyntax(item: .stmt(stmt))
                }
                return item?.with(\.trailingTrivia, .newline)
            })),
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