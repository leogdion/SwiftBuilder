import SwiftSyntax

public struct ParameterExp: CodeBlock {
    let name: String
    let value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
    
    public var syntax: SyntaxProtocol {
        if name.isEmpty {
            return ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(value)))
        } else {
            return LabeledExprSyntax(
                label: .identifier(name),
                colon: .colonToken(),
                expression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(value)))
            )
        }
    }
} 