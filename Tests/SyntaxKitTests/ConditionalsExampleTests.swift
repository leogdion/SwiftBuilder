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
      Variable(.let, name: "possibleName", type: "String?", equals: "\"John\"").withExplicitType()
        .comment {
          Line("Multiple optional bindings")
        }
      Variable(.let, name: "possibleAge", type: "Int?", equals: "30").withExplicitType()

      If {
        Let("name", "possibleName")
        Let("age", "possibleAge")
      } then: {
        Call("print") {
          ParameterExp(name: "", value: "\"\\(name) is \\(age) years old\"")
        }
      }

      // MARK: - Guard Statements
      Function(
        "greet",
        {
          Parameter(name: "person", type: "[String: String]")
        }
      ) {
        Guard {
          Let("name", "person[\"name\"]")
        } else: {
          Call("print") {
            ParameterExp(name: "", value: "\"No name provided\"")
          }
        }

        Guard {
          Let("age", "person[\"age\"]")
          Let("ageInt", "Int(age)")
        } else: {
          Call("print") {
            ParameterExp(name: "", value: "\"Invalid age provided\"")
          }
        }

        Call("print") {
          ParameterExp(name: "", value: "\"Hello \\(name), you are \\(ageInt) years old\"")
        }
      }
      .comment {
        Line("MARK: - Guard Statements")
      }

      // MARK: - Switch Statements
      Variable(.let, name: "approximateCount", type: "Int", equals: "62")
        .comment {
          Line("MARK: - Switch Statements")
          Line("Switch with range matching")
        }
      Variable(
        .let,
        name: "countedThings",
        type: "String",
        equals: "\"moons orbiting Saturn\""
      )
      Variable(.let, name: "naturalCount", type: "String").withExplicitType()
      Switch("approximateCount") {
        SwitchCase(0) {
          Assignment("naturalCount", Literal.string("no"))
        }
        SwitchCase(1..<5) {
          Assignment("naturalCount", Literal.string("a few"))
        }
        SwitchCase(5..<12) {
          Assignment("naturalCount", Literal.string("several"))
        }
        SwitchCase(12..<100) {
          Assignment("naturalCount", Literal.string("dozens of"))
        }
        SwitchCase(100..<1_000) {
          Assignment("naturalCount", Literal.string("hundreds of"))
        }
        Default {
          Assignment("naturalCount", Literal.string("many"))
        }
      }
      Call("print") {
        ParameterExp(name: "", value: "\"There are \\(naturalCount) \\(countedThings).\"")
      }

      // MARK: - Tuple literal and tuple pattern switch
      Variable(.let, name: "somePoint", equals: TupleLiteral([.int(1), .int(1)]))
        .comment {
          Line("Switch with tuple matching")
        }
      Switch("somePoint") {
        SwitchCase(Tuple.pattern([0, 0])) {
          Call("print") {
            ParameterExp(name: "", value: "\"(0, 0) is at the origin\"")
          }
        }
        SwitchCase(Tuple.pattern([nil, 0])) {
          Call("print") {
            ParameterExp(name: "", value: "\"(\\(somePoint.0), 0) is on the x-axis\"")
          }
        }
        SwitchCase(Tuple.pattern([0, nil])) {
          Call("print") {
            ParameterExp(name: "", value: "\"(0, \\(somePoint.1)) is on the y-axis\"")
          }
        }
        SwitchCase(Tuple.pattern([(-2...2), (-2...2)])) {
          Call("print") {
            ParameterExp(
              name: "", value: "\"(\\(somePoint.0), \\(somePoint.1)) is inside the box\"")
          }
        }
        Default {
          Call("print") {
            ParameterExp(
              name: "", value: "\"(\\(somePoint.0), \\(somePoint.1)) is outside of the box\"")
          }
        }
      }
    }

    // Generate Swift from DSL
    var generated = program.generateCode()
    // Print just the generated switch statement for debugging
    let switchStmt = Switch("approximateCount") {
      SwitchCase(0) {
        Assignment("naturalCount", Literal.string("no"))
      }
      SwitchCase(1..<5) {
        Assignment("naturalCount", Literal.string("a few"))
      }
      SwitchCase(5..<12) {
        Assignment("naturalCount", Literal.string("several"))
      }
      SwitchCase(12..<100) {
        Assignment("naturalCount", Literal.string("dozens of"))
      }
      SwitchCase(100..<1_000) {
        Assignment("naturalCount", Literal.string("hundreds of"))
      }
      Default {
        Assignment("naturalCount", Literal.string("many"))
      }
    }

    // Remove type annotations like ": Int =" for comparison to example code
    generated = generated.normalize()

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
