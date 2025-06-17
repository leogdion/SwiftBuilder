import XCTest
@testable import SyntaxKit

final class SyntaxKitTestsA: XCTestCase {
    func testBlackjackCardExample() throws {
        let blackjackCard = Struct("BlackjackCard") {
            Enum("Suit") {
                EnumCase("spades").equals("♠")
                EnumCase("hearts").equals("♡")
                EnumCase("diamonds").equals("♢")
                EnumCase("clubs").equals("♣")
            }.inherits("Character")
        }
        
        let expected = """
        struct BlackjackCard {
            enum Suit: Character {
                case spades = "♠"
                case hearts = "♡"
                case diamonds = "♢"
                case clubs = "♣"
            }
        }
        """
        
        // Normalize whitespace, remove comments and modifiers, and normalize colon spacing
        let normalizedGenerated = blackjackCard.syntax.description
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
