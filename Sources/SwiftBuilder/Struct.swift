import SwiftSyntax

public struct Struct: CodeBlock {
    private let name: String
    private let members: [CodeBlock]
    private var inheritance: String?
    private var genericParameter: String?
    
    public init(_ name: String, generic: String? = nil, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.name = name
        self.members = content()
        self.genericParameter = generic
    }
    
    public func inherits(_ type: String) -> Self {
        var copy = self
        copy.inheritance = type
        return copy
    }
    
    public var syntax: SyntaxProtocol {
        let structKeyword = TokenSyntax.keyword(.struct, trailingTrivia: .space)
        let identifier = TokenSyntax.identifier(name)
        
        var genericParameterClause: GenericParameterClauseSyntax?
        if let generic = genericParameter {
            let genericParameter = GenericParameterSyntax(
                name: .identifier(generic),
                trailingComma: nil
            )
            genericParameterClause = GenericParameterClauseSyntax(
                leftAngle: .leftAngleToken(),
                parameters: GenericParameterListSyntax([genericParameter]),
                rightAngle: .rightAngleToken()
            )
        }
        
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
        
        return StructDeclSyntax(
            structKeyword: structKeyword,
            name: identifier,
            genericParameterClause: genericParameterClause,
            inheritanceClause: inheritanceClause,
            memberBlock: memberBlock
        )
    }
} 
