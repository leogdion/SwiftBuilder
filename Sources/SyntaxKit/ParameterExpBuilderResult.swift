import Foundation

@resultBuilder
public struct ParameterExpBuilderResult {
    public static func buildBlock(_ components: ParameterExp...) -> [ParameterExp] {
        components
    }
    
    public static func buildOptional(_ component: ParameterExp?) -> [ParameterExp] {
        component.map { [$0] } ?? []
    }
    
    public static func buildEither(first: ParameterExp) -> [ParameterExp] {
        [first]
    }
    
    public static func buildEither(second: ParameterExp) -> [ParameterExp] {
        [second]
    }
    
    public static func buildArray(_ components: [ParameterExp]) -> [ParameterExp] {
        components
    }
} 