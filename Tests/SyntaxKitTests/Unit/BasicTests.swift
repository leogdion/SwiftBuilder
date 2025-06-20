import Testing

@testable import SyntaxKit

internal struct BasicTests {
  @Test internal func testBlackjackCardExample() throws {
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
    let normalizedGenerated = blackjackCard.syntax.description.normalize()

    let normalizedExpected = expected.normalize()

    #expect(normalizedGenerated == normalizedExpected)
  }
}

@Suite
final class ForLoopTests {
    @Test
    func testSimpleForInLoop() {
        let forLoop = For(
            VariableExp("item"),
            in: VariableExp("items"),
            then: {
                Call("print") {
                    ParameterExp(name: "", value: "item")
                }
            }
        )
        let generated = forLoop.syntax.description
        let expected = "for item in items {\n    print(item)\n}"
        #expect(generated.contains("for item in items"))
        #expect(generated.contains("print(item)"))
    }

    @Test
    func testForInWithWhereClause() {
        let forLoop = For(
            VariableExp("number"),
            in: VariableExp("numbers"),
            where: Infix("%") {
                VariableExp("number")
                Literal.integer(2)
            },
            then: {
                Call("print") {
                    ParameterExp(name: "", value: "number")
                }
            }
        )
        let generated = forLoop.syntax.description
        #expect(generated.contains("for number in numbers where number % 2"))
        #expect(generated.contains("print(number)"))
    }
}
