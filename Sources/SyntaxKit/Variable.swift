//
//  Variable.swift
//  SyntaxKit
//
//  Created by Leo Dion on 6/15/25.
//
import SwiftSyntax

public struct Variable: CodeBlock {
    private let kind: VariableKind
    private let name: String
    private let type: String
    private let defaultValue: String?
    
    public init(_ kind: VariableKind, name: String, type: String, equals defaultValue: String? = nil) {
        self.kind = kind
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }
    
    public var syntax: SyntaxProtocol {
        let bindingKeyword = TokenSyntax.keyword(kind == .let ? .let : .var, trailingTrivia: .space)
        let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
        let typeAnnotation = TypeAnnotationSyntax(
            colon: .colonToken(leadingTrivia: .space, trailingTrivia: .space),
            type: IdentifierTypeSyntax(name: .identifier(type))
        )
        
        let initializer = defaultValue.map { value in
            InitializerClauseSyntax(
                equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                value: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(value)))
            )
        }
        
        return VariableDeclSyntax(
            bindingSpecifier: bindingKeyword,
            bindings: PatternBindingListSyntax([
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: identifier),
                    typeAnnotation: typeAnnotation,
                    initializer: initializer
                )
            ])
        )
    }
}
