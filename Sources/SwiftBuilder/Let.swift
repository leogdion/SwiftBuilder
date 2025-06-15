import SwiftSyntax

public struct Let: CodeBlock {
    let name: String
    let value: String
    public init(_ name: String, _ value: String) {
        self.name = name
        self.value = value
    }
    public var syntax: SyntaxProtocol {
        return CodeBlockItemSyntax(
            item: .decl(
                DeclSyntax(
                    VariableDeclSyntax(
                        bindingSpecifier: .keyword(.let, trailingTrivia: .space),
                        bindings: PatternBindingListSyntax([
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: .identifier(name)),
                                initializer: InitializerClauseSyntax(
                                    equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                                    value: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(value)))
                                )
                            )
                        ])
                    )
                )
            )
        )
    }
} 