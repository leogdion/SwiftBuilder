import SwiftSyntax

public struct VariableDecl: CodeBlock {
    private let kind: VariableKind
    private let name: String
    private let value: String?
    
    public init(_ kind: VariableKind, name: String, equals value: String? = nil) {
        self.kind = kind
        self.name = name
        self.value = value
    }
    
    public var syntax: SyntaxProtocol {
        let bindingKeyword = TokenSyntax.keyword(kind == .let ? .let : .var, trailingTrivia: .space)
        let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
        let initializer = value.map { value in
            if value.hasPrefix("\"") && value.hasSuffix("\"") || value.contains("\\(") {
                return InitializerClauseSyntax(
                    equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                    value: StringLiteralExprSyntax(
                        openingQuote: .stringQuoteToken(),
                        segments: StringLiteralSegmentListSyntax([
                            .stringSegment(StringSegmentSyntax(content: .stringSegment(String(value.dropFirst().dropLast()))))
                        ]),
                        closingQuote: .stringQuoteToken()
                    )
                )
            } else {
                return InitializerClauseSyntax(
                    equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                    value: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(value)))
                )
            }
        }
        return VariableDeclSyntax(
            bindingSpecifier: bindingKeyword,
            bindings: PatternBindingListSyntax([
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: identifier),
                    typeAnnotation: nil,
                    initializer: initializer
                )
            ])
        )
    }
} 