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

    Variable(.let, "possibleName", type: "String?", equals: "John")
      .comment {
        Line("Multiple optional bindings")
      }
    Variable(.let, "possibleAge", type: "Int?", equals: 30)
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