import Foundation
import SwiftSyntax

public protocol CodeBlock {
    var syntax: SyntaxProtocol { get }
}

public protocol CodeBlockBuilder {
    associatedtype Result: CodeBlock
    func build() -> Result
}

@resultBuilder
public struct CodeBlockBuilderResult {
    public static func buildBlock(_ components: CodeBlock...) -> [CodeBlock] {
        components
    }
    
    public static func buildExpression(_ expression: CodeBlock) -> CodeBlock {
        expression
    }
    
    public static func buildOptional(_ component: CodeBlock?) -> CodeBlock {
        component ?? EmptyCodeBlock()
    }
    
    public static func buildEither(first: CodeBlock) -> CodeBlock {
        first
    }
    
    public static func buildEither(second: CodeBlock) -> CodeBlock {
        second
    }
    
    public static func buildArray(_ components: [CodeBlock]) -> [CodeBlock] {
        components
    }
}

public struct EmptyCodeBlock: CodeBlock {
    public var syntax: SyntaxProtocol {
      StringSegmentSyntax(content:.unknown(""))
    }
} 
