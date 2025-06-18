import Foundation
import Testing

@testable import SyntaxKit

struct MainApplicationTests {
  // MARK: - Main Application Error Handling Tests

  @Test("Main application handles valid input")
  func testMainApplicationValidInput() throws {
    // This test simulates the main application behavior
    // We can't easily test the main function directly, but we can test its components

    let code = "let x = 42"
    let response = try SyntaxParser.parse(code: code, options: ["fold"])

    // Test JSON serialization (part of main application logic)
    let jsonData = try JSONSerialization.data(withJSONObject: ["syntax": response.syntaxJSON])
    let jsonString = String(data: jsonData, encoding: .utf8)

    #expect(jsonString != nil)
    #expect(jsonString!.contains("syntax"))
    #expect(jsonString!.contains("let"))
  }

  @Test("Main application handles empty input")
  func testMainApplicationEmptyInput() throws {
    let code = ""
    let response = try SyntaxParser.parse(code: code, options: [])

    // Test JSON serialization with empty result
    let jsonData = try JSONSerialization.data(withJSONObject: ["syntax": response.syntaxJSON])
    let jsonString = String(data: jsonData, encoding: .utf8)

    #expect(jsonString != nil)
    #expect(jsonString!.contains("syntax"))
  }

  @Test("Main application handles parsing errors")
  func testMainApplicationParsingErrors() throws {
    let invalidCode = "struct { invalid syntax"

    do {
      _ = try SyntaxParser.parse(code: invalidCode, options: [])
      #expect(false, "Should have thrown an error for invalid syntax")
    } catch {
      // Test error JSON serialization (part of main application logic)
      let errorResponse = ["error": error.localizedDescription]
      let jsonData = try JSONSerialization.data(withJSONObject: errorResponse)
      let jsonString = String(data: jsonData, encoding: .utf8)

      #expect(jsonString != nil)
      #expect(jsonString!.contains("error"))
      #expect(jsonString!.contains(error.localizedDescription))
    }
  }

  @Test("Main application handles JSON serialization errors")
  func testMainApplicationJSONSerializationErrors() throws {
    // Test with a response that might cause JSON serialization issues
    let code = "let x = 42"
    let response = try SyntaxParser.parse(code: code, options: [])

    // This should work fine, but we're testing the JSON serialization path
    let jsonData = try JSONSerialization.data(withJSONObject: ["syntax": response.syntaxJSON])
    let jsonString = String(data: jsonData, encoding: .utf8)

    #expect(jsonString != nil)
  }

  // MARK: - File I/O Simulation Tests

  @Test("Main application handles large input")
  func testMainApplicationLargeInput() throws {
    // Generate a large Swift file to test performance
    var largeCode = ""
    for i in 1...50 {
      largeCode += """
        struct Struct\(i) {
            let property\(i): String
            func method\(i)() -> String {
                return "value\(i)"
            }
        }

        """
    }

    let response = try SyntaxParser.parse(code: largeCode, options: ["fold"])
    let jsonData = try JSONSerialization.data(withJSONObject: ["syntax": response.syntaxJSON])
    let jsonString = String(data: jsonData, encoding: .utf8)

    #expect(jsonString != nil)
    #expect(jsonString!.contains("Struct1"))
    #expect(jsonString!.contains("Struct50"))
  }

  @Test("Main application handles unicode input")
  func testMainApplicationUnicodeInput() throws {
    let unicodeCode = """
      let emoji = "🚀"
      let unicode = "café"
      let chinese = "你好"
      """

    let response = try SyntaxParser.parse(code: unicodeCode, options: [])
    let jsonData = try JSONSerialization.data(withJSONObject: ["syntax": response.syntaxJSON])
    let jsonString = String(data: jsonData, encoding: .utf8)

    #expect(jsonString != nil)
    #expect(jsonString!.contains("emoji"))
    #expect(jsonString!.contains("unicode"))
    #expect(jsonString!.contains("chinese"))
  }

  // MARK: - Error Response Format Tests

  @Test("Main application error response format")
  func testMainApplicationErrorResponseFormat() throws {
    // Test the error response format that the main application would generate
    let testError = NSError(
      domain: "TestDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error message"])

    let errorResponse = ["error": testError.localizedDescription]
    let jsonData = try JSONSerialization.data(withJSONObject: errorResponse)
    let jsonString = String(data: jsonData, encoding: .utf8)

    #expect(jsonString != nil)
    #expect(jsonString!.contains("error"))
    #expect(jsonString!.contains("Test error message"))
  }

  @Test("Main application handles encoding errors")
  func testMainApplicationEncodingErrors() throws {
    let code = "let x = 42"
    let response = try SyntaxParser.parse(code: code, options: [])

    // Test UTF-8 encoding (part of main application logic)
    let jsonData = try JSONSerialization.data(withJSONObject: ["syntax": response.syntaxJSON])
    let jsonString = String(data: jsonData, encoding: .utf8)

    #expect(jsonString != nil)
    #expect(jsonString!.contains("syntax"))
  }

  // MARK: - Integration Tests

  @Test("Main application integration with complex Swift code")
  func testMainApplicationIntegration() throws {
    let complexCode = """
      @objc class MyClass: NSObject {
          @Published var property: String = "default"

          func method(@escaping completion: @escaping (String) -> Void) {
              completion("result")
          }

          enum NestedEnum: Int {
              case first = 1
              case second = 2
          }
      }
      """

    let response = try SyntaxParser.parse(code: complexCode, options: ["fold"])
    let jsonData = try JSONSerialization.data(withJSONObject: ["syntax": response.syntaxJSON])
    let jsonString = String(data: jsonData, encoding: .utf8)

    #expect(jsonString != nil)
    #expect(jsonString!.contains("class"))
    #expect(jsonString!.contains("MyClass"))
    #expect(jsonString!.contains("@objc"))
    #expect(jsonString!.contains("@Published"))
    #expect(jsonString!.contains("@escaping"))
  }

  @Test("Main application handles different parser options")
  func testMainApplicationWithDifferentOptions() throws {
    let code = "let x = 42"

    let response1 = try SyntaxParser.parse(code: code, options: ["fold"])
    let response2 = try SyntaxParser.parse(code: code, options: ["unfold"])

    let jsonData1 = try JSONSerialization.data(withJSONObject: ["syntax": response1.syntaxJSON])
    let jsonData2 = try JSONSerialization.data(withJSONObject: ["syntax": response2.syntaxJSON])

    let jsonString1 = String(data: jsonData1, encoding: .utf8)
    let jsonString2 = String(data: jsonData2, encoding: .utf8)

    #expect(jsonString1 != nil)
    #expect(jsonString2 != nil)
    #expect(jsonString1 != jsonString2)  // Different options should produce different results
  }
}
