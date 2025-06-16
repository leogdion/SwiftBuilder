import SwiftSyntax

public struct If: CodeBlock {
    private let condition: CodeBlock
    private let body: [CodeBlock]
    private let elseBody: [CodeBlock]?
    
    public init(_ condition: CodeBlock, @CodeBlockBuilderResult then: () -> [CodeBlock], else elseBody: (() -> [CodeBlock])? = nil) {
        self.condition = condition
        self.body = then()
        self.elseBody = elseBody?()
    }
    
    public var syntax: SyntaxProtocol {
        let cond: ConditionElementSyntax
        if let letCond = condition as? Let {
            cond = ConditionElementSyntax(
                condition: .optionalBinding(
                    OptionalBindingConditionSyntax(
                        bindingSpecifier: .keyword(.let, trailingTrivia: .space),
                        pattern: IdentifierPatternSyntax(identifier: .identifier(letCond.name)),
                        initializer: InitializerClauseSyntax(
                            equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                            value: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(letCond.value)))
                        )
                    )
                )
            )
        } else {
            cond = ConditionElementSyntax(
                condition: .expression(ExprSyntax(fromProtocol: condition.syntax.as(ExprSyntax.self) ?? DeclReferenceExprSyntax(baseName: .identifier(""))))
            )
        }
        let bodyBlock = CodeBlockSyntax(
            leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
            statements: CodeBlockItemListSyntax(body.compactMap {
                var item: CodeBlockItemSyntax?
                if let decl = $0.syntax.as(DeclSyntax.self) {
                    item = CodeBlockItemSyntax(item: .decl(decl))
                } else if let expr = $0.syntax.as(ExprSyntax.self) {
                    item = CodeBlockItemSyntax(item: .expr(expr))
                } else if let stmt = $0.syntax.as(StmtSyntax.self) {
                    item = CodeBlockItemSyntax(item: .stmt(stmt))
                }
                return item?.with(\.trailingTrivia, .newline)
            }),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        let elseBlock = elseBody.map {
            IfExprSyntax.ElseBody(CodeBlockSyntax(
                leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
                statements: CodeBlockItemListSyntax($0.compactMap {
                    var item: CodeBlockItemSyntax?
                    if let decl = $0.syntax.as(DeclSyntax.self) {
                        item = CodeBlockItemSyntax(item: .decl(decl))
                    } else if let expr = $0.syntax.as(ExprSyntax.self) {
                        item = CodeBlockItemSyntax(item: .expr(expr))
                    } else if let stmt = $0.syntax.as(StmtSyntax.self) {
                        item = CodeBlockItemSyntax(item: .stmt(stmt))
                    }
                    return item?.with(\.trailingTrivia, .newline)
                }),
                rightBrace: .rightBraceToken(leadingTrivia: .newline)
            ))
        }
        return ExprSyntax(
            IfExprSyntax(
                ifKeyword: .keyword(.if, trailingTrivia: .space),
                conditions: ConditionElementListSyntax([cond]),
                body: bodyBlock,
                elseKeyword: elseBlock != nil ? .keyword(.else, trailingTrivia: .space) : nil,
                elseBody: elseBlock
            )
        )
    }
} 