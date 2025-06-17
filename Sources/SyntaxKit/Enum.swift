import SwiftSyntax

public struct Enum: CodeBlock {
    private let name: String
    private let members: [CodeBlock]
    private var inheritance: String?
    
    public init(_ name: String, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.name = name
        self.members = content()
    }
    
    public func inherits(_ type: String) -> Self {
        var copy = self
        copy.inheritance = type
        return copy
    }
    
    public var syntax: SyntaxProtocol {
        let enumKeyword = TokenSyntax.keyword(.enum, trailingTrivia: .space)
        let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
        
        var inheritanceClause: InheritanceClauseSyntax?
        if let inheritance = inheritance {
            let inheritedType = InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier(inheritance)))
            inheritanceClause = InheritanceClauseSyntax(colon: .colonToken(), inheritedTypes: InheritedTypeListSyntax([inheritedType]))
        }
        
        let memberBlock = MemberBlockSyntax(
            leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
            members: MemberBlockItemListSyntax(members.compactMap { member in
                guard let syntax = member.syntax.as(DeclSyntax.self) else { return nil }
                return MemberBlockItemSyntax(decl: syntax, trailingTrivia: .newline)
            }),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        
        return EnumDeclSyntax(
            enumKeyword: enumKeyword,
            name: identifier,
            inheritanceClause: inheritanceClause,
            memberBlock: memberBlock
        )
    }
}

public struct EnumCase: CodeBlock {
    private let name: String
    private var value: String?
    private var intValue: Int?
    
    public init(_ name: String) {
        self.name = name
    }
    
    public func equals(_ value: String) -> Self {
        var copy = self
        copy.value = value
        copy.intValue = nil
        return copy
    }
    
    public func equals(_ value: Int) -> Self {
        var copy = self
        copy.value = nil
        copy.intValue = value
        return copy
    }
    
    public var syntax: SyntaxProtocol {
        let caseKeyword = TokenSyntax.keyword(.case, trailingTrivia: .space)
        let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
        
        var initializer: InitializerClauseSyntax?
        if let value = value {
            initializer = InitializerClauseSyntax(
                equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                value: StringLiteralExprSyntax(
                    openingQuote: .stringQuoteToken(),
                    segments: StringLiteralSegmentListSyntax([
                        .stringSegment(StringSegmentSyntax(content: .stringSegment(value)))
                    ]),
                    closingQuote: .stringQuoteToken()
                )
            )
        } else if let intValue = intValue {
            initializer = InitializerClauseSyntax(
                equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                value: IntegerLiteralExprSyntax(digits: .integerLiteral(String(intValue)))
            )
        }
        
        return EnumCaseDeclSyntax(
            caseKeyword: caseKeyword,
            elements: EnumCaseElementListSyntax([
                EnumCaseElementSyntax(
                    leadingTrivia: .space,
                    _: nil,
                    name: identifier,
                    _: nil,
                    parameterClause: nil,
                    _: nil,
                    rawValue: initializer,
                    _: nil,
                    trailingComma: nil,
                    trailingTrivia: .newline
                )
            ])
        )
    }
} 
