//
//  PlusAssign.swift
//  SyntaxKit
//
//  Created by Leo Dion on 6/15/25.
//
import SwiftSyntax

public struct PlusAssign: CodeBlock {
    private let target: String
    private let value: String
    
    public init(_ target: String, _ value: String) {
        self.target = target
        self.value = value
    }
    
    public var syntax: SyntaxProtocol {
        let left = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(target)))
        let right: ExprSyntax
        if value.hasPrefix("\"") && value.hasSuffix("\"") || value.contains("\\(") {
            right = ExprSyntax(StringLiteralExprSyntax(
                openingQuote: .stringQuoteToken(),
                segments: StringLiteralSegmentListSyntax([
                    .stringSegment(StringSegmentSyntax(content: .stringSegment(String(value.dropFirst().dropLast()))))
                ]),
                closingQuote: .stringQuoteToken()
            ))
        } else {
            right = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(value)))
        }
        let assign = ExprSyntax(BinaryOperatorExprSyntax(operator: .binaryOperator("+=", leadingTrivia: .space, trailingTrivia: .space)))
        return SequenceExprSyntax(
            elements: ExprListSyntax([
                left,
                assign,
                right
            ])
        )
    }
}
