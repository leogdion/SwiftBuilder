import Foundation
import Testing

@testable import SyntaxKit

@Suite internal struct ConditionalsExampleTests {
  // swiftlint:disable function_body_length
  @Test("Completed conditionals DSL generates expected Swift code")
  internal func testCompletedConditionalsExample() throws {
    // Build DSL equivalent of Examples/Completed/conditionals/dsl.swift
    // swiftlint:disable:next closure_body_length
    let program = Group {
      // MARK: Basic If Statements
      Variable(.let, name: "temperature", type: "Int", equals: "25")
        .comment {
          Line("Simple if statement")
        }

      If {
        Infix(">") {
          VariableExp("temperature")
          Literal.integer(30)
        }
      } then: {
        Call("print") {
          ParameterExp(name: "", value: "\"It's hot outside!\"")
        }
      }

      // If-else chain with else-if
      Variable(.let, name: "score", type: "Int", equals: "85")
        .comment {
          Line("If-else statement")
        }

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

        If {
          Infix(">=") {
            VariableExp("score")
            Literal.integer(70)
          }
        } then: {
          Call("print") {
            ParameterExp(name: "", value: "\"Passing\"")
          }
        }

        Then {
          Call("print") {
            ParameterExp(name: "", value: "\"Needs improvement\"")
          }
        }
      }

      // MARK: Optional Binding with If
      Variable(.let, name: "possibleNumber", type: "String", equals: "\"123\"")
        .comment {
          Line("MARK: - Optional Binding with If")
          Line("Using if let for optional binding")
        }

      If(
        Let("actualNumber", "Int(possibleNumber)"),
        then: {
          Call("print") {
            ParameterExp(
              name: "",
              value:
                "\"The string \\\"\\(possibleNumber)\\\" has an integer value of \\(actualNumber)\""
            )
          }
        },
        else: {
          Call("print") {
            ParameterExp(
              name: "",
              value:
                "\"The string \\\"\\(possibleNumber)\\\" could not be converted to an integer\"")
          }
        })

      // Multiple optional bindings
      Variable(.let, name: "possibleName", type: "String?", equals: "\"John\"")
        .comment {
          Line("Multiple optional bindings")
        }
      Variable(.let, name: "possibleAge", type: "Int?", equals: "30")

      If {
        Let("name", "possibleName")
        Let("age", "possibleAge")
      } then: {
        Call("print") {
          ParameterExp(name: "", value: "\"\\(name) is \\(age) years old\"")
        }
      }
    }

    // Generate Swift from DSL
    var generated = program.generateCode()
    // Remove type annotations like ": Int =" for comparison to example code
    generated = generated.replacingOccurrences(
      of: ":\\s*\\w+\\s*=", with: "=", options: .regularExpression
    )
    .normalize()

    // Load expected Swift from example file
    let projectRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let expectedURL = projectRoot.appendingPathComponent(
      "Examples/Completed/conditionals/code.swift")
    var expected = try String(contentsOf: expectedURL)
      .normalize()

    #expect(generated == expected)
  }
  // swiftlint:enable function_body_length
}
