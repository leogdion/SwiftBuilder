//
//  VariableExp.swift
//  SyntaxKit
//
//  Created by Leo Dion on 6/15/25.
//
import SwiftSyntax

public struct VariableExp: CodeBlock {
    let name: String
    
    public init(_ name: String) {
        self.name = name
    }
    
    public func property(_ propertyName: String) -> CodeBlock {
        return PropertyAccessExp(baseName: name, propertyName: propertyName)
    }
    
    public func call(_ methodName: String) -> CodeBlock {
        return FunctionCallExp(baseName: name, methodName: methodName)
    }
    
    public func call(_ methodName: String, @ParameterExpBuilderResult _ params: () -> [ParameterExp]) -> CodeBlock {
        return FunctionCallExp(baseName: name, methodName: methodName, parameters: params())
    }
    
    public var syntax: SyntaxProtocol {
        return TokenSyntax.identifier(name)
    }
}

public struct PropertyAccessExp: CodeBlock {
    let baseName: String
    let propertyName: String
    
    public init(baseName: String, propertyName: String) {
        self.baseName = baseName
        self.propertyName = propertyName
    }
    
    public var syntax: SyntaxProtocol {
        let base = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(baseName)))
        let property = TokenSyntax.identifier(propertyName)
        return ExprSyntax(MemberAccessExprSyntax(
            base: base,
            dot: .periodToken(),
            name: property
        ))
    }
}

public struct FunctionCallExp: CodeBlock {
    let baseName: String
    let methodName: String
    let parameters: [ParameterExp]
    
    public init(baseName: String, methodName: String) {
        self.baseName = baseName
        self.methodName = methodName
        self.parameters = []
    }
    
    public init(baseName: String, methodName: String, parameters: [ParameterExp]) {
        self.baseName = baseName
        self.methodName = methodName
        self.parameters = parameters
    }
    
    public var syntax: SyntaxProtocol {
        let base = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(baseName)))
        let method = TokenSyntax.identifier(methodName)
        let args = LabeledExprListSyntax(parameters.enumerated().map { index, param in
            let expr = param.syntax
            if let labeled = expr as? LabeledExprSyntax {
                var element = labeled
                if index < parameters.count - 1 {
                    element = element.with(\.trailingComma, .commaToken(trailingTrivia: .space))
                }
                return element
            } else if let unlabeled = expr as? ExprSyntax {
                return TupleExprElementSyntax(
                    label: nil,
                    colon: nil,
                    expression: unlabeled,
                    trailingComma: index < parameters.count - 1 ? .commaToken(trailingTrivia: .space) : nil
                )
            } else {
                fatalError("ParameterExp.syntax must return LabeledExprSyntax or ExprSyntax")
            }
        })
        return ExprSyntax(FunctionCallExprSyntax(
            calledExpression: ExprSyntax(MemberAccessExprSyntax(
                base: base,
                dot: .periodToken(),
                name: method
            )),
            leftParen: .leftParenToken(),
            arguments: args,
            rightParen: .rightParenToken()
        ))
    }
}
