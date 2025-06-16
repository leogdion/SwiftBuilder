import SwiftSyntax

public enum Literal: CodeBlock {
    case string(String)
    case float(Double)
    case integer(Int)
    case `nil`
    case boolean(Bool)

    public var syntax: SyntaxProtocol {
        switch self {
        case .string(let value):
            return StringLiteralExprSyntax(
                openingQuote: .stringQuoteToken(),
                segments: .init([
                    .stringSegment(.init(content: .stringSegment(value)))
                ]),
                closingQuote: .stringQuoteToken()
            )
        case .float(let value):
            return FloatLiteralExprSyntax(literal: .floatLiteral(String(value)))

        case .integer(let value):
            return IntegerLiteralExprSyntax(digits: .integerLiteral(String(value)))
        case .nil:
            return NilLiteralExprSyntax(nilKeyword: .keyword(.nil))
        case .boolean(let value):
            return BooleanLiteralExprSyntax(literal: value ? .keyword(.true) : .keyword(.false))
        }
    }
} 
