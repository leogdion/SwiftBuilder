//
//  Variable.swift
//  SwiftBuilder
//
//  Created by Leo Dion on 6/15/25.
//
import SwiftSyntax

public struct Variable: CodeBlock {
    private let kind: VariableKind
    private let name: String
    private let type: String
    
    public init(_ kind: VariableKind, name: String, type: String) {
        self.kind = kind
        self.name = name
        self.type = type
    }
    
    public var syntax: SyntaxProtocol {
        let bindingKeyword = TokenSyntax.keyword(kind == .let ? .let : .var, trailingTrivia: .space)
        let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
        let typeAnnotation = TypeAnnotationSyntax(
            colon: .colonToken(leadingTrivia: .space, trailingTrivia: .space),
            type: IdentifierTypeSyntax(name: .identifier(type))
        )
        
        return VariableDeclSyntax(
            bindingSpecifier: bindingKeyword,
            bindings: PatternBindingListSyntax([
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: identifier),
                    typeAnnotation: typeAnnotation
                )
            ])
        )
    }
}
