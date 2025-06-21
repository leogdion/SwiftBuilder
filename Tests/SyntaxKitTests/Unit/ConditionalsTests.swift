import Testing

@testable import SyntaxKit

@Suite internal struct ConditionalsTests {
  @Test("If / else-if / else chain generates correct syntax")
  internal func testIfElseChain() throws {
    // Arrange: build the DSL example using the updated APIs
    let conditional = Group {
      Variable(.let, name: "score", type: "Int", equals: "85")

      If {
        Infix(">=") {
          VariableExp("score")
          Literal.integer(90)
        }
      } then: {
        Call("print") {
          ParameterExp(name: "", value: "\"Excellent!\"")
        }
      } else: {
        If {
          Infix(">=") {
            VariableExp("score")
            Literal.integer(80)
          }
        } then: {
          Call("print") {
            ParameterExp(name: "", value: "\"Good job!\"")
          }
        }

        Then {
          Call("print") {
            ParameterExp(name: "", value: "\"Needs improvement\"")
          }
        }
      }
    }

    // Act
    let generated = conditional.generateCode().normalize()

    // Assert key structure is present
    #expect(generated.contains("let score".normalize()))
    #expect(generated.contains("if score >= 90".normalize()))
    #expect(generated.contains("else if score >= 80".normalize()))
    #expect(generated.contains("else {".normalize()))
  }
}
