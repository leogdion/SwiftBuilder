import Foundation
import SwiftSyntax
import SwiftParser

public enum VariableKind {
    case `let`
    case `var`
}

public struct Struct: CodeBlock {
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
        let structKeyword = TokenSyntax.keyword(.struct, trailingTrivia: .space)
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
        
        return StructDeclSyntax(
            structKeyword: structKeyword,
            name: identifier,
            inheritanceClause: inheritanceClause,
            memberBlock: memberBlock
        )
    }
}

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

public struct SwitchCase: CodeBlock {
    private let patterns: [String]
    private let body: [CodeBlock]
    
    public init(_ patterns: String..., @CodeBlockBuilderResult content: () -> [CodeBlock]) {
        self.patterns = patterns
        self.body = content()
    }
    
    public var switchCaseSyntax: SwitchCaseSyntax {
        let caseItems = SwitchCaseItemListSyntax(patterns.enumerated().map { index, pattern in
            var item = SwitchCaseItemSyntax(
                pattern: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier(pattern)))
            )
            if index < patterns.count - 1 {
                item = item.with(\.trailingComma, .commaToken(trailingTrivia: .space))
            }
            return item
        })
        let statements = CodeBlockItemListSyntax(body.compactMap { $0.syntax.as(CodeBlockItemSyntax.self) })
        let label = SwitchCaseLabelSyntax(
            caseKeyword: .keyword(.case, trailingTrivia: .space),
            caseItems: caseItems,
            colon: .colonToken(trailingTrivia: .newline)
        )
        return SwitchCaseSyntax(
            label: .case(label),
            statements: statements
        )
    }
    
    public var syntax: SyntaxProtocol { switchCaseSyntax }
}

public struct Case: CodeBlock {
    private let patterns: [String]
    private let body: [CodeBlock]
    
    public init(_ patterns: String..., @CodeBlockBuilderResult content: () -> [CodeBlock]) {
        self.patterns = patterns
        self.body = content()
    }
    
    public var switchCaseSyntax: SwitchCaseSyntax {
        let patternList = TuplePatternElementListSyntax(
            patterns.map { TuplePatternElementSyntax(
                label: nil,
                colon: nil,
                pattern: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier($0)))
            )}
        )
        let caseItems = CaseItemListSyntax([
            CaseItemSyntax(
                pattern: TuplePatternSyntax(
                    leftParen: .leftParenToken(),
                    elements: patternList,
                    rightParen: .rightParenToken()
                )
            )
        ])
        let statements = CodeBlockItemListSyntax(body.compactMap { $0.syntax.as(CodeBlockItemSyntax.self) })
        let label = SwitchCaseLabelSyntax(
            caseKeyword: .keyword(.case, trailingTrivia: .space),
            caseItems: caseItems,
            colon: .colonToken()
        )
        return SwitchCaseSyntax(
            label: .case(label),
            statements: statements
        )
    }
    
    public var syntax: SyntaxProtocol { switchCaseSyntax }
}

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

public struct ComputedProperty: CodeBlock {
    private let name: String
    private let type: String
    private let body: [CodeBlock]
    
    public init(_ name: String, type: String, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.name = name
        self.type = type
        self.body = content()
    }
    
    public var syntax: SyntaxProtocol {
        let statements = CodeBlockItemListSyntax(self.body.compactMap { item in
            if let cb = item.syntax as? CodeBlockItemSyntax { return cb.with(\ .trailingTrivia, .newline) }
            if let stmt = item.syntax as? StmtSyntax {
                return CodeBlockItemSyntax(item: .stmt(stmt), trailingTrivia: .newline)
            }
            if let expr = item.syntax as? ExprSyntax {
                return CodeBlockItemSyntax(item: .expr(expr), trailingTrivia: .newline)
            }
            return nil
        })
        let accessor = AccessorBlockSyntax(
            leftBrace: TokenSyntax.leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
            accessors: .getter(statements),
            rightBrace: TokenSyntax.rightBraceToken(leadingTrivia: .newline)
        )
        let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
        let typeAnnotation = TypeAnnotationSyntax(
            colon: TokenSyntax.colonToken(leadingTrivia: .space, trailingTrivia: .space),
            type: IdentifierTypeSyntax(name: .identifier(type))
        )
        return VariableDeclSyntax(
            bindingSpecifier: TokenSyntax.keyword(.var, trailingTrivia: .space),
            bindings: PatternBindingListSyntax([
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: identifier),
                    typeAnnotation: typeAnnotation,
                    accessorBlock: accessor
                )
            ])
        )
    }
}

public struct Switch: CodeBlock {
    private let expression: String
    private let cases: [CodeBlock]
    
    public init(_ expression: String, @CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.expression = expression
        self.cases = content()
    }
    
    public var syntax: SyntaxProtocol {
        let expr = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(expression)))
        let casesArr: [SwitchCaseSyntax] = self.cases.compactMap {
            if let c = $0 as? SwitchCase { return c.switchCaseSyntax }
            if let d = $0 as? Default { return d.switchCaseSyntax }
            return nil
        }
        let cases = SwitchCaseListSyntax(casesArr.map { SwitchCaseListSyntax.Element.init($0) })
        let switchExpr = SwitchExprSyntax(
            switchKeyword: .keyword(.switch, trailingTrivia: .space),
            subject: expr,
            leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
            cases: cases,
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        return CodeBlockItemSyntax(item: .expr(ExprSyntax(switchExpr)))
    }
}

public struct Default: CodeBlock {
    private let body: [CodeBlock]
    public init(@CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.body = content()
    }
    public var switchCaseSyntax: SwitchCaseSyntax {
        let statements = CodeBlockItemListSyntax(body.compactMap { $0.syntax.as(CodeBlockItemSyntax.self) })
        let label = SwitchDefaultLabelSyntax(
            defaultKeyword: .keyword(.default, trailingTrivia: .space),
            colon: .colonToken()
        )
        return SwitchCaseSyntax(
            label: .default(label),
            statements: statements
        )
    }
    public var syntax: SyntaxProtocol { switchCaseSyntax }
}

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
        return CodeBlockItemSyntax(
            item: .decl(
                DeclSyntax(
                    VariableDeclSyntax(
                        bindingSpecifier: bindingKeyword,
                        bindings: PatternBindingListSyntax([
                            PatternBindingSyntax(
                                pattern: IdentifierPatternSyntax(identifier: identifier),
                                typeAnnotation: nil,
                                initializer: initializer
                            )
                        ])
                    )
                )
            ),
            trailingTrivia: .newline
        )
    }
}

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
        return CodeBlockItemSyntax(
            item: .expr(
                ExprSyntax(
                    SequenceExprSyntax(
                        elements: ExprListSyntax([
                            left,
                            assign,
                            right
                        ])
                    )
                )
            ),
            trailingTrivia: .newline
        )
    }
}

public struct Assignment: CodeBlock {
    private let target: String
    private let value: String
    public init(_ target: String, _ value: String) {
        self.target = target
        self.value = value
    }
    public var syntax: SyntaxProtocol {
        let left = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(target)))
        let right = ExprSyntax(StringLiteralExprSyntax(
            openingQuote: .stringQuoteToken(),
            segments: StringLiteralSegmentListSyntax([
                .stringSegment(StringSegmentSyntax(content: .stringSegment(value)))
            ]),
            closingQuote: .stringQuoteToken()
        ))
        let assign = ExprSyntax(AssignmentExprSyntax(assignToken: .equalToken()))
        return CodeBlockItemSyntax(
            item: .expr(
                ExprSyntax(
                    SequenceExprSyntax(
                        elements: ExprListSyntax([
                            left,
                            assign,
                            right
                        ])
                    )
                )
            ),
            trailingTrivia: .newline
        )
    }
}

public struct Return: CodeBlock {
    private let exprs: [CodeBlock]
    public init(@CodeBlockBuilderResult _ content: () -> [CodeBlock]) {
        self.exprs = content()
    }
    public var syntax: SyntaxProtocol {
        guard let expr = exprs.first else {
            fatalError("Return must have at least one expression.")
        }
        if let varExp = expr as? VariableExp {
            return CodeBlockItemSyntax(
                item: .stmt(
                    StmtSyntax(
                        ReturnStmtSyntax(
                            returnKeyword: .keyword(.return, trailingTrivia: .space),
                            expression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(varExp.name)))
                        )
                    )
                ),
                trailingTrivia: .newline
            )
        }
        return CodeBlockItemSyntax(
            item: .stmt(
                StmtSyntax(
                    ReturnStmtSyntax(
                        returnKeyword: .keyword(.return, trailingTrivia: .space),
                        expression: ExprSyntax(expr.syntax)
                    )
                )
            ),
            trailingTrivia: .newline
        )
    }
}

public struct If: CodeBlock {
    private let condition: CodeBlock
    private let body: [CodeBlock]
    private let elseBody: [CodeBlock]?
    
    public init(_ condition: CodeBlock, @CodeBlockBuilderResult then: () -> [CodeBlock], else elseBody: (() -> [CodeBlock])? = nil) {
        self.condition = condition
        self.body = then()
        self.elseBody = elseBody?()
    }
    
    public var syntax: SyntaxProtocol {
        let cond: ConditionElementSyntax
        if let letCond = condition as? Let {
            cond = ConditionElementSyntax(
                condition: .optionalBinding(
                    OptionalBindingConditionSyntax(
                        bindingSpecifier: .keyword(.let, trailingTrivia: .space),
                        pattern: IdentifierPatternSyntax(identifier: .identifier(letCond.name)),
                        initializer: InitializerClauseSyntax(
                            equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                            value: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(letCond.value)))
                        )
                    )
                )
            )
        } else {
            cond = ConditionElementSyntax(
                condition: .expression(ExprSyntax(fromProtocol: condition.syntax.as(ExprSyntax.self) ?? DeclReferenceExprSyntax(baseName: .identifier(""))))
            )
        }
        let bodyBlock = CodeBlockSyntax(
            leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
            statements: CodeBlockItemListSyntax(body.compactMap { $0.syntax.as(CodeBlockItemSyntax.self) }),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        let elseBlock = elseBody.map {
            IfExprSyntax.ElseBody(CodeBlockSyntax(
                leftBrace: .leftBraceToken(leadingTrivia: .space, trailingTrivia: .newline),
                statements: CodeBlockItemListSyntax($0.compactMap { $0.syntax.as(CodeBlockItemSyntax.self) }),
                rightBrace: .rightBraceToken(leadingTrivia: .newline)
            ))
        }
        return ExprSyntax(
            IfExprSyntax(
                ifKeyword: .keyword(.if, trailingTrivia: .space),
                conditions: ConditionElementListSyntax([cond]),
                body: bodyBlock,
                elseKeyword: elseBlock != nil ? .keyword(.else, trailingTrivia: .space) : nil,
                elseBody: elseBlock
            )
        )
    }
}

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

@resultBuilder
public struct ParameterBuilderResult {
    public static func buildBlock(_ components: Parameter...) -> [Parameter] {
        components
    }
    
    public static func buildOptional(_ component: Parameter?) -> [Parameter] {
        component.map { [$0] } ?? []
    }
    
    public static func buildEither(first: Parameter) -> [Parameter] {
        [first]
    }
    
    public static func buildEither(second: Parameter) -> [Parameter] {
        [second]
    }
    
    public static func buildArray(_ components: [Parameter]) -> [Parameter] {
        components
    }
}

public struct Init: CodeBlock {
    private let type: String
    private let parameters: [Parameter]
    public init(_ type: String, @ParameterBuilderResult _ params: () -> [Parameter]) {
        self.type = type
        self.parameters = params()
    }
    public var syntax: SyntaxProtocol {
        let args = TupleExprElementListSyntax(parameters.enumerated().map { index, param in
            let element = param.syntax as! TupleExprElementSyntax
            if index < parameters.count - 1 {
                return element.with(\.trailingComma, .commaToken(trailingTrivia: .space))
            }
            return element
        })
        return ExprSyntax(FunctionCallExprSyntax(
            calledExpression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(type))),
            leftParen: .leftParenToken(),
            argumentList: args,
            rightParen: .rightParenToken()
        ))
    }
}

public struct Parameter: CodeBlock {
    private let name: String
    private let value: String
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
    public var syntax: SyntaxProtocol {
        return TupleExprElementSyntax(
            label: .identifier(name),
            colon: .colonToken(),
            expression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(value)))
        )
    }
}

public struct VariableExp: CodeBlock {
    let name: String
    
    public init(_ name: String) {
        self.name = name
    }
    
    public var syntax: SyntaxProtocol {
       return TokenSyntax.identifier(self.name)
    }
}

public struct OldVariableExp: CodeBlock {
    private let name: String
    private let value: String
    
    public init(_ name: String, _ value: String) {
        self.name = name
        self.value = value
    }
    
    public var syntax: SyntaxProtocol {
        let name = TokenSyntax.identifier(self.name)
        let value = IdentifierExprSyntax(identifier: .identifier(self.value))
        
        return OptionalBindingConditionSyntax(
            bindingSpecifier: .keyword(.let, trailingTrivia: .space),
            pattern: IdentifierPatternSyntax(identifier: name),
            initializer: InitializerClauseSyntax(
                equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                value: value
            )
        )
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

