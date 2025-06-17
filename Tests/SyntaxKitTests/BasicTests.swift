import Testing

@testable import SyntaxKit

struct BasicTests {
    @Test func testBlackjackCardExample() throws {
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
            .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s*:\\s*", with: ": ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let normalizedExpected =
            expected
            .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s*:\\s*", with: ": ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        #expect(normalizedGenerated == normalizedExpected)
    }
}
