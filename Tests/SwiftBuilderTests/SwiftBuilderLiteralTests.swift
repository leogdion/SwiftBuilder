import XCTest
@testable import SwiftBuilder

final class SwiftBuilderLiteralTests: XCTestCase {
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