import Testing

@testable import SyntaxKit

struct LiteralTests {
  @Test func testGroupWithLiterals() {
    let group = Group {
      Return {
        Literal.integer(1)
      }
    }
    let generated = group.generateCode()
    #expect(generated.trimmingCharacters(in: .whitespacesAndNewlines) == "return 1")
  }
}
