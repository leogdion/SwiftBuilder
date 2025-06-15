import Foundation
import SwiftSyntax
import SwiftParser

public struct Parameter: CodeBlock {
    let name: String
    let type: String
    let defaultValue: String?
    public init(name: String, type: String, defaultValue: String? = nil) {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }
    public var syntax: SyntaxProtocol {
        // Not used for function signature, but for call sites (Init, etc.)
        if let defaultValue = defaultValue {
            return LabeledExprSyntax(
                label: .identifier(name),
                colon: .colonToken(),
                expression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(defaultValue)))
            )
        } else {
            return LabeledExprSyntax(
                label: .identifier(name),
                colon: .colonToken(),
                expression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(name)))
            )
        }
    }
} 