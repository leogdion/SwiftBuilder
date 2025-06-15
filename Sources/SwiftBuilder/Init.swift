import SwiftSyntax

public struct Init: CodeBlock {
    private let type: String
    private let parameters: [Parameter]
    public init(_ type: String, @ParameterBuilderResult _ params: () -> [Parameter]) {
        self.type = type
        self.parameters = params()
    }
    public var syntax: SyntaxProtocol {
        let args = TupleExprElementListSyntax(parameters.enumerated().map { index, param in
            let element = param.syntax as! TupleExprElementSyntax
            if index < parameters.count - 1 {
                return element.with(\.trailingComma, .commaToken(trailingTrivia: .space))
            }
            return element
        })
        return ExprSyntax(FunctionCallExprSyntax(
            calledExpression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(type))),
            leftParen: .leftParenToken(),
            argumentList: args,
            rightParen: .rightParenToken()
        ))
    }
} 