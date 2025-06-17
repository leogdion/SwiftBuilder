import Testing

@testable import SyntaxKit

/// Tests for code style and API simplification changes introduced during Swift Testing migration
/// Validates the simplified Swift APIs and formatting changes
struct CodeStyleMigrationTests {
    
    // MARK: - String.CompareOptions Simplification Tests
    
    @Test func testRegularExpressionOptionSimplification() {
        // Test that .regularExpression works instead of String.CompareOptions.regularExpression
        let testCode = "public func test() { // comment }"
        
        // Old style: String.CompareOptions.regularExpression
        // New style: .regularExpression
        let withoutComments = testCode.replacingOccurrences(
            of: "//.*$", with: "", options: .regularExpression
        )
        let withoutPublic = withoutComments.replacingOccurrences(
            of: "public\\s+", with: "", options: .regularExpression
        )
        
        #expect(withoutPublic.trimmingCharacters(in: .whitespacesAndNewlines) == "func test() { }")
    }
    
    @Test func testAllStringOptionsSimplifications() {
        let testString = "public struct Test: Protocol { // docs }"
        
        // Test the complete pipeline of string replacements used in the migrated tests
        let normalized = testString
            .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s*:\\s*", with: ": ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        #expect(normalized == "struct Test: Protocol { }")
    }
    
    // MARK: - CharacterSet Simplification Tests
    
    @Test func testCharacterSetSimplification() {
        // Test that .whitespacesAndNewlines works instead of CharacterSet.whitespacesAndNewlines
        let testString = "\n  test content  \n\t"
        
        // Old style: CharacterSet.whitespacesAndNewlines
        // New style: .whitespacesAndNewlines
        let trimmed = testString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        #expect(trimmed == "test content")
    }
    
    // MARK: - Indentation and Formatting Tests
    
    @Test func testConsistentIndentationInMigratedCode() throws {
        // Test that the indentation changes in the migrated code work correctly
        let syntax = Struct("IndentationTest") {
            Variable(.let, name: "property1", type: "String")
            Variable(.let, name: "property2", type: "Int")
            
            Function("method") {
                Parameter(name: "param", type: "String")
            } _: {
                VariableDecl(.let, name: "local", equals: "\"value\"")
                Return {
                    VariableExp("local")
                }
            }
        }
        
        let generated = syntax.generateCode()
        
        // Verify proper indentation is maintained
        #expect(generated.contains("struct IndentationTest"))
        #expect(generated.contains("    let property1: String"))
        #expect(generated.contains("    let property2: Int"))
        #expect(generated.contains("    func method(param: String)"))
    }
    
    // MARK: - Multiline String Formatting Tests
    
    @Test func testMultilineStringFormatting() {
        let expected = """
            struct TestStruct {
                let value: String
                var count: Int
            }
            """
        
        let syntax = Struct("TestStruct") {
            Variable(.let, name: "value", type: "String")
            Variable(.var, name: "count", type: "Int")
        }
        
        let normalized = syntax.generateCode()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let expectedNormalized = expected
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        #expect(normalized == expectedNormalized)
    }
    
    @Test func testMigrationPreservesCodeGeneration() {
        // Ensure that the style changes don't break core functionality
        let group = Group {
            Return {
                Literal.string("migrated")
            }
        }
        
        let generated = group.generateCode().trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(generated == "return \"migrated\"")
    }
}