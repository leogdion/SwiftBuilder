Variable(.var, "vendingMachine", equals: Init("VendingMachine"))
Assignment("vendingMachine.coinsDeposited", Literal.integer(8))
Do{
    Call("buyFavoriteSnack"){
        ParameterExp("person", Literal.string("Alice"))
        ParameterExp("vendingMachine", Literal.ref("vendingMachine"))
    }.throwing()
    Call("print", Literal.string("Success! Yum."))
    }
} catch: {
    Catch(EnumCase("VendingMachineError.invalidSelection")) {
        Call("print", Literal.string("Invalid Selection."))
    }
    Catch(EnumCase("VendingMachineError.outOfStock")) {
        Call("print",  Literal.string("Out of Stock."))
    }
    Catch(EnumCase("VendingMachineError.insufficientFunds").associatedValue("coinsNeeded", type: "Int")) {
        Call("print", Literal.string("Insufficient funds. Please insert an additional \\(coinsNeeded) coins."))
    }
    Catch {
        Call("print", Literal.string("Unexpected error: \\(error)."))
    }
}










