import Foundation

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