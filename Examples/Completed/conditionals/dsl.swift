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
Variable(.let, "anotherPoint", equals: TupleLiteral([.int(2), .int(0)])).withExplicitType()
.comment {
    Line("Switch with value binding")
}
Switch("anotherPoint") {
    SwitchCase(Tuple.pattern([.let("x"), 0])) {
        Call("print", "on the x-axis with an x value of \\(x)")
        
    }
    SwitchCase(Tuple.pattern([0, .let("y")])) {
        Call("print", "on the y-axis with a y value of \\(y)")
     
    }
    SwitchCase(Tuple.pattern([.let("x"), .let("y")])) {
        Call("print", "somewhere else at (\\(x), \\(y))")
        
    }
}
Variable(.let, "integerToDescribe", equals: 5)
Variable(.var, "description", equals: "The number \\(integerToDescribe) is")
Switch("integerToDescribe") {
    SwitchCase(2, 3, 5, 7, 11, 13, 17, 19) {
        PlusAssign("description", "a prime number, and also")
        Fallthrough()
    }
    Default {
        PlusAssign("description", "an integer.")
    }
}
Call("print", "description")

Variable(.let, "finalSquare", equals: 25)
Variable(.var, "board", equals: Init("[Int]") {
    Parameter("repeating", 0)
    Parameter("count", "finalSquare + 1")
})

Infix("board[03]", "+=", 8)
Infix("board[06]", "+=", 11)
Infix("board[09]", "+=", 9)
Infix("board[10]", "+=", 2)
Infix("board[14]", "-=", 10)
Infix("board[19]", "-=", 11)
Infix("board[22]", "-=", 2)
Infix("board[24]", "-=", 8)

Variable(.var, "square", equals: 0)
Variable(.var, "diceRoll", equals: 0)
While {
    Infix("square", "!=", "finalSquare")
} then: {
    Assignment("diceRoll", "+", 1)
    If {
        Infix("diceRoll", "==", 7)
    } then: {
        Assignment("diceRoll", 1)
    }
    Switch(Infix("square", "+", "diceRoll")) {
        SwitchCase("finalSquare") {
            Break()
        }
        SwitchCase(Infix("newSquare", ">", "finalSquare")) {
            Continue()
        }
        Default {
            Infix("square", "+=", "diceRoll")
            Infix("square", "+=", "board[square]")
        }
    }
}