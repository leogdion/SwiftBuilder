import XCTest

@testable import SyntaxKit

final class LiteralTests: XCTestCase {
  func testGroupWithLiterals() {
    let group = Group {
      Return {
        Literal.integer(1)
      }
    }
    let generated = group.generateCode()
    XCTAssertEqual(generated.trimmingCharacters(in: .whitespacesAndNewlines), "return 1")
  }
}
