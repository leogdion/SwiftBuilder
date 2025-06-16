import XCTest
@testable import SwiftBuilder

final class SwiftBuilderCommentTests: XCTestCase {
    func testCommentInjection() {
        let syntax = Struct("Foo") {
            Variable(.let, name: "bar", type: "Int")
        }
        .comment {
            Line("MARK: - Models")
            Line(.doc, "Foo struct docs")
        }

        let generated = syntax.syntax.description
        print("Generated:\n", generated)

        XCTAssertTrue(generated.contains("MARK: - Models"), "MARK line should be present in generated code")
        XCTAssertTrue(generated.contains("Foo struct docs"), "Doc comment line should be present in generated code")
        // Ensure the struct declaration itself is still correct
        XCTAssertTrue(generated.contains("struct Foo"))
        XCTAssertTrue(generated.contains("bar"), "Variable declaration should be present")
    }
} 