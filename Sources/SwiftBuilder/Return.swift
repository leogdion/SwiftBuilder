import SwiftSyntax

public struct Return: CodeBlock {
    private let exprs: [CodeBlock]
    public init(@CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.exprs = content()
    }
    public var syntax: SyntaxProtocol {
        guard let expr = exprs.first else {
            fatalError("Return must have at least one expression.")
        }
        if let varExp = expr as? VariableExp {
            return ReturnStmtSyntax(
                returnKeyword: .keyword(.return, trailingTrivia: .space),
                expression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(varExp.name)))
            )
        }
        return ReturnStmtSyntax(
            returnKeyword: .keyword(.return, trailingTrivia: .space),
            expression: ExprSyntax(expr.syntax)
        )
    }
} 