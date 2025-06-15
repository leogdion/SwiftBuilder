
import SwiftSyntax

public struct Function: CodeBlock {
    private let name: String
    private let parameters: [Parameter]
    private let returnType: String?
    private let body: [CodeBlock]
    private var isStatic: Bool = false
    private var isMutating: Bool = false
    
    public init(_ name: String, @ParameterBuilderResult _ params: () -> [Parameter], returns returnType: String? = nil, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.name = name
        self.parameters = params()
        self.returnType = returnType
        self.body = content()
    }
    
    public func `static`() -> Self {
        var copy = self
        copy.isStatic = true
        return copy
    }
    
    public func mutating() -> Self {
        var copy = self
        copy.isMutating = true
        return copy
    }
    
    public var syntax: SyntaxProtocol {
        let funcKeyword = TokenSyntax.keyword(.func, trailingTrivia: .space)
        let identifier = TokenSyntax.identifier(name)
        
        // Build parameter list
        let paramList = FunctionParameterListSyntax(parameters.enumerated().map { index, param in
            var paramSyntax = FunctionParameterSyntax(
                firstName: .identifier(param.name),
                secondName: nil,
                colon: .colonToken(leadingTrivia: .space, trailingTrivia: .space),
                type: IdentifierTypeSyntax(name: .identifier(param.type)),
                defaultValue: param.defaultValue.map {
                    InitializerClauseSyntax(
                        equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                        value: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier($0)))
                    )
                }
            )
            if index < parameters.count - 1 {
                paramSyntax = paramSyntax.with(\.trailingComma, .commaToken(trailingTrivia: .space))
            }
            return paramSyntax
        })
        
        // Build return type if specified
        var returnClause: ReturnClauseSyntax?
        if let returnType = returnType {
            returnClause = ReturnClauseSyntax(
                arrow: .arrowToken(leadingTrivia: .space, trailingTrivia: .space),
                type: IdentifierTypeSyntax(name: .identifier(returnType))
            )
        }
        
        // Build function body
        let statements = CodeBlockItemListSyntax(body.compactMap { item in
            if let cb = item.syntax as? CodeBlockItemSyntax { return cb.with(\.trailingTrivia, .newline) }
            if let stmt = item.syntax as? StmtSyntax {
                return CodeBlockItemSyntax(item: .stmt(stmt), trailingTrivia: .newline)
            }
            if let expr = item.syntax as? ExprSyntax {
                return CodeBlockItemSyntax(item: .expr(expr), trailingTrivia: .newline)
            }
            return nil
        })
        
        let bodyBlock = CodeBlockSyntax(
            leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
            statements: statements,
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        
        // Build modifiers
        var modifiers: DeclModifierListSyntax = []
        if isStatic {
            modifiers = DeclModifierListSyntax([
                DeclModifierSyntax(name: .keyword(.static, trailingTrivia: .space))
            ])
        }
        if isMutating {
            modifiers = DeclModifierListSyntax(modifiers + [
                DeclModifierSyntax(name: .keyword(.mutating, trailingTrivia: .space))
            ])
        }
        
        return FunctionDeclSyntax(
            attributes: AttributeListSyntax([]),
            modifiers: modifiers,
            funcKeyword: funcKeyword,
            name: identifier,
            genericParameterClause: nil,
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    leftParen: .leftParenToken(),
                    parameters: paramList,
                    rightParen: .rightParenToken()
                ),
                effectSpecifiers: nil,
                returnClause: returnClause
            ),
            genericWhereClause: nil,
            body: bodyBlock
        )
    }
} 
