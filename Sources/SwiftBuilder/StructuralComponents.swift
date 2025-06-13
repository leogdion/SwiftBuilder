import Foundation
import SwiftSyntax

public struct Struct: CodeBlock {
    private let name: String
    private let members: [CodeBlock]
    private var inheritance: String?
    private var comment: String?
    
    public init(_ name: String, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.name = name
        self.members = content()
    }
    
    public func inherits(_ type: String) -> Self {
        var copy = self
        copy.inheritance = type
        return copy
    }
    
    public func comment(_ text: String) -> Self {
        var copy = self
        copy.comment = text
        return copy
    }
    
    public var syntax: SyntaxProtocol {
        let structKeyword = TokenSyntax.keyword(.struct, trailingTrivia: .space)
        let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
        
        var inheritanceClause: TypeInheritanceClauseSyntax?
        if let inheritance = inheritance {
            let inheritedType = InheritedTypeSyntax(type: SimpleTypeIdentifierSyntax(name: .identifier(inheritance)))
            inheritanceClause = TypeInheritanceClauseSyntax(colon: .colonToken(), inheritedTypeCollection: InheritedTypeListSyntax([inheritedType]))
        }
        
        let memberBlock = MemberBlockSyntax(
            leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
            members: MemberDeclListSyntax(members.compactMap { member in
                guard let syntax = member.syntax.as(DeclSyntax.self) else { return nil }
                return MemberDeclListItemSyntax(decl: syntax, trailingTrivia: .newline)
            }),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        
        let modifiers = comment.map { _ in
            DeclModifierListSyntax([
                DeclModifierSyntax(name: .keyword(.public, trailingTrivia: .space))
            ])
        }
        
        return StructDeclSyntax(
            modifiers: modifiers ?? [],
            structKeyword: structKeyword,
            identifier: identifier,
            inheritanceClause: inheritanceClause,
            memberBlock: memberBlock
        )
    }
}

public struct Enum: CodeBlock {
    private let name: String
    private let content: [CodeBlock]
    private var inheritance: String?
    private var comment: String?
    
    public init(_ name: String, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.name = name
        self.content = content()
    }
    
    public func inherits(_ type: String) -> Self {
        var copy = self
        copy.inheritance = type
        return copy
    }
    
    public func comment(_ text: String) -> Self {
        var copy = self
        copy.comment = text
        return copy
    }
    
    public var syntax: SyntaxProtocol {
        let enumKeyword = TokenSyntax.keyword(.enum, trailingTrivia: .space)
        let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
        
        var inheritanceClause: TypeInheritanceClauseSyntax?
        if let inheritance = inheritance {
            let inheritedType = InheritedTypeSyntax(type: SimpleTypeIdentifierSyntax(name: .identifier(inheritance)))
            inheritanceClause = TypeInheritanceClauseSyntax(colon: .colonToken(), inheritedTypeCollection: InheritedTypeListSyntax([inheritedType]))
        }
        
        let memberBlock = MemberBlockSyntax(
            leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
            members: MemberDeclListSyntax(content.compactMap { item in
                guard let caseBlock = item as? Case else { return nil }
                return MemberDeclListItemSyntax(decl: caseBlock.enumCaseDeclaration, trailingTrivia: .newline)
            }),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        
        let modifiers = comment.map { _ in
            DeclModifierListSyntax([
                DeclModifierSyntax(name: .keyword(.public, trailingTrivia: .space))
            ])
        }
        
        return EnumDeclSyntax(
            modifiers: modifiers ?? [],
            enumKeyword: enumKeyword,
            identifier: identifier,
            inheritanceClause: inheritanceClause,
            memberBlock: memberBlock
        )
    }
}

public struct Case: CodeBlock {
    private let name: String
    private var value: String?
    
    public init(_ name: String) {
        self.name = name
    }
    
    public func equals(_ value: String) -> Self {
        var copy = self
        copy.value = value
        return copy
    }
    
    public var enumCaseDeclaration: EnumCaseDeclSyntax {
        let caseKeyword = TokenSyntax.keyword(.case, trailingTrivia: .space)
        let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
        
        var rawValue: InitializerClauseSyntax?
        if let value = value {
            let stringLiteral = StringLiteralExprSyntax(
                openingQuote: .stringQuoteToken(),
                segments: StringLiteralSegmentListSyntax([
                    .stringSegment(StringSegmentSyntax(content: .stringSegment(value)))
                ]),
                closingQuote: .stringQuoteToken()
            )
            rawValue = InitializerClauseSyntax(
                equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                value: stringLiteral
            )
        }
        
        return EnumCaseDeclSyntax(
            caseKeyword: caseKeyword,
            elements: EnumCaseElementListSyntax([
                EnumCaseElementSyntax(
                    name: identifier,
                    rawValue: rawValue
                )
            ])
        )
    }
    
    public var syntax: SyntaxProtocol {
        return self.enumCaseDeclaration
    }
}

public extension CodeBlock {
    func generateCode() -> String {
        guard let decl = syntax as? DeclSyntaxProtocol else {
            fatalError("Only declaration syntax is supported at the top level.")
        }
        let sourceFile = SourceFileSyntax(
            statements: CodeBlockItemListSyntax([
                CodeBlockItemSyntax(item: .decl(DeclSyntax(decl)))
            ])
        )
      return sourceFile.description
    }
}

public extension Array where Element == CodeBlock {
    func generateCode() -> String {
        let decls = compactMap { $0.syntax as? DeclSyntaxProtocol }
        let sourceFile = SourceFileSyntax(
            statements: CodeBlockItemListSyntax(decls.map { decl in
                CodeBlockItemSyntax(item: .decl(DeclSyntax(decl)))
            })
        )
        return sourceFile.description
    }
} 
