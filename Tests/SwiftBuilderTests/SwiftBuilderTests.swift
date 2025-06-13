import XCTest
@testable import SwiftBuilder

final class SwiftBuilderTests: XCTestCase {
    func testBlackjackCardExample() throws {
        let blackjackCard = Struct("BlackjackCard") {
            Enum("Suit") {
                Case("spades").equals("♠")
                Case("hearts").equals("♡")
                Case("diamonds").equals("♢")
                Case("clubs").equals("♣")
            }.inherits("Character")
        }
        
        let expected = """
        struct BlackjackCard {
            // nested Suit enumeration
            enum Suit: Character {
                case spades = "♠"
                case hearts = "♡"
                case diamonds = "♢"
                case clubs = "♣"
            }
        }
        """
        
        // Normalize whitespace and remove comments and modifiers
        let normalizedGenerated = blackjackCard.syntax.description
            .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression) // Remove comments
            .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression) // Remove public modifier
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // Normalize whitespace
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let normalizedExpected = expected
            .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression) // Remove comments
            .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression) // Remove public modifier
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // Normalize whitespace
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        XCTAssertEqual(normalizedGenerated, normalizedExpected)
    }
}
