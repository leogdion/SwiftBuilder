import XCTest
@testable import SwiftBuilder

final class SwiftBuilderTestsC: XCTestCase {
    func testBasicFunction() throws {
        let function = Function("calculateSum", {
            Parameter(name: "a", type: "Int")
            Parameter(name: "b", type: "Int")
        }, returns: "Int") {
            Return {
                VariableExp("a + b")
            }
        }
        
        let expected = """
        func calculateSum(a: Int, b: Int) -> Int {
            return a + b
        }
        """
        
        // Normalize whitespace, remove comments and modifiers, and normalize colon spacing
        let normalizedGenerated = function.syntax.description
            .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression) // Remove comments
            .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression) // Remove public modifier
            .replacingOccurrences(of: "\\s*:\\s*", with: ": ", options: .regularExpression) // Normalize colon spacing
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // Normalize whitespace
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let normalizedExpected = expected
            .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression) // Remove comments
            .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression) // Remove public modifier
            .replacingOccurrences(of: "\\s*:\\s*", with: ": ", options: .regularExpression) // Normalize colon spacing
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // Normalize whitespace
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        XCTAssertEqual(normalizedGenerated, normalizedExpected)
    }
    
    func testStaticFunction() throws {
        let function = Function("createInstance", {
            Parameter(name: "value", type: "String")
        }, returns: "MyType") {
            Return {
                Init("MyType") {
                    Parameter(name: "value", type: "String")
                }
            }
        }.static()
        
        let expected = """
        static func createInstance(value: String) -> MyType {
            return MyType(value: value)
        }
        """
        
        // Normalize whitespace, remove comments and modifiers, and normalize colon spacing
        let normalizedGenerated = function.syntax.description
            .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression) // Remove comments
            .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression) // Remove public modifier
            .replacingOccurrences(of: "\\s*:\\s*", with: ": ", options: .regularExpression) // Normalize colon spacing
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // Normalize whitespace
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let normalizedExpected = expected
            .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression) // Remove comments
            .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression) // Remove public modifier
            .replacingOccurrences(of: "\\s*:\\s*", with: ": ", options: .regularExpression) // Normalize colon spacing
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // Normalize whitespace
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        XCTAssertEqual(normalizedGenerated, normalizedExpected)
    }
    
    func testMutatingFunction() throws {
        let function = Function("updateValue", {
            Parameter(name: "newValue", type: "String")
        }) {
            Assignment("value", "newValue")
        }.mutating()
        
        let expected = """
        mutating func updateValue(newValue: String) {
            value = newValue
        }
        """
        
        // Normalize whitespace, remove comments and modifiers, and normalize colon spacing
        let normalizedGenerated = function.syntax.description
            .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression) // Remove comments
            .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression) // Remove public modifier
            .replacingOccurrences(of: "\\s*:\\s*", with: ": ", options: .regularExpression) // Normalize colon spacing
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // Normalize whitespace
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let normalizedExpected = expected
            .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression) // Remove comments
            .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression) // Remove public modifier
            .replacingOccurrences(of: "\\s*:\\s*", with: ": ", options: .regularExpression) // Normalize colon spacing
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // Normalize whitespace
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        XCTAssertEqual(normalizedGenerated, normalizedExpected)
    }
} 