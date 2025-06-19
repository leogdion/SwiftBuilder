Group {
    Variable(.let, "temperature", equals: 25)
      .comment {
        Line("Simple if statement")
      }
    If {
        Infix("temperature", ">", 30)
    } then: {
        Call("print", "It's hot outside!")
    }
    Variable(.let, "score", equals: 85)
      .comment {
        Line("If-else statement")
      }
    If {
        Infix("score", ">=", 90)
    } then: {
        Call("print", "Excellent!")
    } else: {
        If {
            Infix("score", ">=", 80)
        } then: {
            Call("print", "Good job!")
        }
        If {
            Infix("score", ">=", 70)
        } then: {
            Call("print", "Passing")
        }
        Then {
            Call("print", "Needs improvement")
        }
    }

    Variable(.let, "possibleNumber", equals: "123")
      .comment {
        Line("MARK: - Optional Binding with If")
        Line("Using if let for optional binding")
      }
    If(Let("actualNumber", Init("Int") {
        Parameter(unlabeled: "possibleNumber")
    }), then: {
        Call("print", "The string \"\\(possibleNumber)\" has an integer value of \\(actualNumber)")
    }, else: {
        Call("print", "The string \"\\(possibleNumber)\" could not be converted to an integer")
    })

    Variable(.let, "possibleName", type: "String?", equals: "John").withExplicitType()
      .comment {
        Line("Multiple optional bindings")
      }
    Variable(.let, "possibleAge", type: "Int?", equals: 30).withExplicitType()
    If {
        Let("name", "possibleName")
        Let("age", "possibleAge")
    } then: {
        Call("print", "\\(name) is \\(age) years old") 
    }

    Function("greet", parameters: [Parameter("person", type: "[String: String]")]) {
        Guard {
            Let("name", "person[\"name\"]")
        } else: {
            Call("print", "No name provided")
        }
        Guard {
            Let("age", "person[\"age\"]")
            Let("ageInt", Init("Int") {
                Parameter(unlabeled: "age")
            })
        } else: {
            Call("print", "Invalid age provided")
        }
        Call("print", "Hello \\(name), you are \\(ageInt) years old")
    }
}.comment {
    Line("MARK: - Guard Statements")
}

Variable(.let, "approximateCount", equals: 62)
  .comment {
    Line("MARK: - Switch Statements")
    Line("Switch with range matching")
  }
Variable(.let, "countedThings", equals: "moons orbiting Saturn")
Variable(.let, "naturalCount", type: "String").withExplicitType()
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
    SwitchCase(100..<1000) {
        Assignment("naturalCount", Literal.string("hundreds of"))
    }
    Default {
        Assignment("naturalCount", Literal.string("many"))
    }
}
Call("print", "There are \\(naturalCount) \\(countedThings).")
Variable(.let, "somePoint", equals: TupleLiteral([.int(1), .int(1)])).withExplicitType()
.comment {
    Line("Switch with tuple matching")
}
Switch("somePoint") {
    SwitchCase(Tuple.pattern([0, 0])) {
        Call("print", "(0, 0) is at the origin")
    }
    SwitchCase(Tuple.pattern([nil, 0])) {
        Call("print", "(\\(somePoint.0), 0) is on the x-axis")
    }
    SwitchCase(Tuple.pattern([0, nil])) {
        Call("print", "(0, \\(somePoint.1)) is on the y-axis")
    }
    SwitchCase(Tuple.pattern([(-2...2), (-2...2)])) {
        Call("print", "(\\(somePoint.0), \\(somePoint.1)) is inside the box")
    }
    Default {
        Call("print", "(\\(somePoint.0), \\(somePoint.1)) is outside of the box")
    }
}
