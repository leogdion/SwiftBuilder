import SwiftSyntax

public struct Function: CodeBlock {
    private let name: String
    private let parameters: [Parameter]
    private let returnType: String?
    private let body: [CodeBlock]
    private var isStatic: Bool = false
    private var isMutating: Bool = false
    
  public init(_ name: String, returns returnType: String? = nil,  @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
      self.name = name
      self.parameters = []
      self.returnType = returnType
      self.body = content()
  }
  
    public init(_ name: String, returns returnType: String? = nil, @ParameterBuilderResult _ params: () -> [Parameter],  @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
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
        let paramList: FunctionParameterListSyntax
        if parameters.isEmpty {
            paramList = FunctionParameterListSyntax([])
        } else {
            paramList = FunctionParameterListSyntax(parameters.enumerated().compactMap { index, param in
                guard !param.name.isEmpty, !param.type.isEmpty else { return nil }
                var paramSyntax = FunctionParameterSyntax(
                    firstName: param.isUnnamed ? .wildcardToken(trailingTrivia: .space) : .identifier(param.name),
                    secondName: param.isUnnamed ? .identifier(param.name) : nil,
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
        }
        
        // Build return type if specified
        var returnClause: ReturnClauseSyntax?
        if let returnType = returnType {
            returnClause = ReturnClauseSyntax(
                arrow: .arrowToken(leadingTrivia: .space, trailingTrivia: .space),
                type: IdentifierTypeSyntax(name: .identifier(returnType))
            )
        }
        
        // Build function body
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
