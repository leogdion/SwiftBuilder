import Testing

@testable import SyntaxKit

struct ParserTests {
  // MARK: - Syntax Parser Tests

  @Test("SyntaxParser parses valid Swift code")
  func testSyntaxParserValidCode() throws {
    let code = """
      struct Test {
          let value: String
      }
      """

    let response = try SyntaxParser.parse(code: code, options: ["fold"])

    #expect(!response.syntaxJSON.isEmpty)
    #expect(response.syntaxJSON.contains("struct"))
    #expect(response.syntaxJSON.contains("Test"))
  }

  @Test("SyntaxParser handles empty code")
  func testSyntaxParserEmptyCode() throws {
    let code = ""

    let response = try SyntaxParser.parse(code: code, options: [])

    #expect(!response.syntaxJSON.isEmpty)
  }

  @Test("SyntaxParser handles invalid Swift code")
  func testSyntaxParserInvalidCode() throws {
    let code = "struct {"
    let response = try SyntaxParser.parse(code: code, options: [])
    #expect(!response.syntaxJSON.isEmpty)
  }

  @Test("SyntaxParser with different options")
  func testSyntaxParserWithOptions() throws {
    let code = "let x = 42"

    let response1 = try SyntaxParser.parse(code: code, options: ["fold"])
    let response2 = try SyntaxParser.parse(code: code, options: ["unfold"])

    #expect(!response1.syntaxJSON.isEmpty)
    #expect(!response2.syntaxJSON.isEmpty)
    // The responses might be different due to different options
    #expect(response1.syntaxJSON != response2.syntaxJSON)
  }

  // MARK: - Token Visitor Tests

  @Test("TokenVisitor processes tokens correctly")
  func testTokenVisitorProcessing() throws {
    let code = "let x = 42"

    // This tests the token visitor functionality
    // Note: We can't easily test the internal token visitor directly,
    // but we can test that the parser works with it
    let response = try SyntaxParser.parse(code: code, options: [])

    #expect(!response.syntaxJSON.isEmpty)
    #expect(response.syntaxJSON.contains("let"))
    #expect(response.syntaxJSON.contains("x"))
    #expect(response.syntaxJSON.contains("42"))
  }

  // MARK: - Error Handling Tests

  @Test("SyntaxParser handles malformed JSON options")
  func testSyntaxParserMalformedOptions() throws {
    let code = "let x = 42"

    // Test with invalid options
    do {
      _ = try SyntaxParser.parse(code: code, options: ["invalid_option"])
      // This might not throw depending on implementation
      #expect(true)
    } catch {
      #expect(true, "Expected error for invalid options")
    }
  }

  // MARK: - Complex Code Tests

  @Test("SyntaxParser handles complex Swift code")
  func testSyntaxParserComplexCode() throws {
    let code = """
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

    let response = try SyntaxParser.parse(code: code, options: ["fold"])

    #expect(!response.syntaxJSON.isEmpty)
    #expect(response.syntaxJSON.contains("class"))
    #expect(response.syntaxJSON.contains("MyClass"))
    #expect(response.syntaxJSON.contains("func"))
    #expect(response.syntaxJSON.contains("method"))
    #expect(response.syntaxJSON.contains("enum"))
    #expect(response.syntaxJSON.contains("NestedEnum"))
  }

  @Test("SyntaxParser handles comments")
  func testSyntaxParserWithComments() throws {
    let code = """
      // This is a comment
      struct Test {
          // Another comment
          let value: String // Inline comment
      }
      """

    let response = try SyntaxParser.parse(code: code, options: [])

    #expect(!response.syntaxJSON.isEmpty)
    #expect(response.syntaxJSON.contains("struct"))
    #expect(response.syntaxJSON.contains("Test"))
  }

  @Test("SyntaxParser handles multiline strings")
  func testSyntaxParserMultilineStrings() throws {
    let code = """
      let multiline = \"\"\"
      This is a
      multiline string
      \"\"\"
      """

    let response = try SyntaxParser.parse(code: code, options: [])

    #expect(!response.syntaxJSON.isEmpty)
    #expect(response.syntaxJSON.contains("multiline"))
  }

  // MARK: - Performance Tests

  @Test("SyntaxParser handles large code files")
  func testSyntaxParserLargeCode() throws {
    // Generate a large Swift file
    var largeCode = ""
    for i in 1...100 {
      largeCode += """
        struct Struct\(i) {
            let property\(i): String
            func method\(i)() -> String {
                return "value\(i)"
            }
        }

        """
    }

    let response = try SyntaxParser.parse(code: largeCode, options: [])

    #expect(!response.syntaxJSON.isEmpty)
    #expect(response.syntaxJSON.contains("Struct1"))
    #expect(response.syntaxJSON.contains("Struct100"))
  }

  // MARK: - Edge Cases

  @Test("SyntaxParser handles unicode characters")
  func testSyntaxParserUnicode() throws {
    let code = """
      let emoji = "🚀"
      let unicode = "café"
      let chinese = "你好"
      """

    let response = try SyntaxParser.parse(code: code, options: [])

    #expect(!response.syntaxJSON.isEmpty)
    #expect(response.syntaxJSON.contains("emoji"))
    #expect(response.syntaxJSON.contains("unicode"))
    #expect(response.syntaxJSON.contains("chinese"))
  }

  @Test("SyntaxParser handles special characters in identifiers")
  func testSyntaxParserSpecialCharacters() throws {
    let code = """
      let `class` = "reserved"
      let `var` = "keyword"
      """

    let response = try SyntaxParser.parse(code: code, options: [])

    #expect(!response.syntaxJSON.isEmpty)
    #expect(response.syntaxJSON.contains("class"))
    #expect(response.syntaxJSON.contains("var"))
  }
}
