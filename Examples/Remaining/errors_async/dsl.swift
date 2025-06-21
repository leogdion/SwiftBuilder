Variable(.var, name: "vendingMachine", equals: Init("VendingMachine"))
Assignment("vendingMachine.coinsDeposited", Literal.integer(8))
Do {
    Call("buyFavoriteSnack") {
        ParameterExp(name: "person", value: Literal.string("Alice"))
        ParameterExp(name: "vendingMachine", value: Literal.ref("vendingMachine"))
    }.throwing()
    Call("print") {
        ParameterExp(unlabeled: Literal.string("Success! Yum."))
    }
    } catch: {
    Catch(EnumCase("VendingMachineError.invalidSelection")) {
        Call("print") {
        ParameterExp(unlabeled: Literal.string("Invalid Selection."))
        }
    }
    Catch(EnumCase("VendingMachineError.outOfStock")) {
        Call("print") {
        ParameterExp(unlabeled: Literal.string("Out of Stock."))
        }
    }
    Catch(
        EnumCase("VendingMachineError.insufficientFunds").associatedValue(
        "coinsNeeded", type: "Int")
    ) {
        Call("print") {
        ParameterExp(
            unlabeled: Literal.string(
            "Insufficient funds. Please insert an additional \\(coinsNeeded) coins."))
        }
    }
    Catch {
        Call("print") {
        ParameterExp(unlabeled: Literal.string("Unexpected error: \\(error)."))
        }
    }
}

Function("summarize") {
    Parameter(name: "ratings", type: "[Int]")
} _: {
    Guard{
        VariableExp("ratings").property("isEmpty").not()
    } else: {
        Throw(EnumCase("noRatings"))
    }
}.throws("StatisticsError")


Variable(.let, name: "data") {
    Call("fetchUserData") {
        ParameterExp(name: "id", value: Literal.integer(1))
    }
}.async()
Variable(.let, name: "posts") {
    Call("fetchUserPosts") {
        ParameterExp(name: "id", value: Literal.integer(1))
    }
}.async()
TupleAssignment(["fetchedData", "fetchedPosts"], equals: Tuple {
    VariableExp("data")
    VariableExp("posts")
}).async().throwing()






