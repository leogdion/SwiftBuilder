Group {
    Variable(.let, "temperature", equals: 25)
    If{
        Infix("temperature", ">", 30)
    } then: {
        Call("print", "It's hot outside!")
    }
    Variable(.let, "score", equals: 85)
    If{
        Infix("score", ">=", 90)
    } then:{
        Call("print", "Excellent!")
    } else: {
        If(Infix("score", ">=", 80)) then: {
            Call("print", "Good job!")
        }
        If(Infix("score", ">=", 70)) then: {
            Call("print", "Passing")
        }
        Then {
            Call("print", "Needs improvement")
        }
    }

    Variable(.let, "possibleNumber", equals: "123")
    If(Let("actualNumber", Init("Int") {
        Parameter(unlabeled: "possibleNumber")
    })) then: {
        Call("print", "The string \"\\(possibleNumber)\" has an integer value of \\(actualNumber)")
    } else: {
        Call("print", "The string \"\\(possibleNumber)\" could not be converted to an integer")
    }

    Variable(.let, "possibleName", type: "String?", equals: "John")
    Variable(.let, "possibleAge", type: "Int?", equals: 30)
    If {
        Let("name", "possibleName")
        Let("age", "possibleAge")
    } then: {
        Call("print", "\\(name) is \\(age) years old") 
    }
}