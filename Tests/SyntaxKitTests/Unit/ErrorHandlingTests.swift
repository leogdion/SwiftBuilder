import Testing

@testable import SyntaxKit

@Suite internal struct ErrorHandlingTests {
  @Test("Error handling DSL generates expected Swift code")
  internal func testErrorHandlingExample() throws {
    let errorHandlingExample = Group {
      Variable(.var, name: "vendingMachine", equals: Init("VendingMachine") {})
      Assignment("vendingMachine.coinsDeposited", Literal.integer(8))
      Do{
        Call("buyFavoriteSnack"){
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
        Catch(EnumCase("VendingMachineError.insufficientFunds").associatedValue("coinsNeeded", type: "Int")) {
          Call("print") {
            ParameterExp(unlabeled: Literal.string("Insufficient funds. Please insert an additional \\(coinsNeeded) coins."))
          }
        }
        Catch {
          Call("print") {
            ParameterExp(unlabeled: Literal.string("Unexpected error: \\(error)."))
          }
        }
      }
    }

    let generated = errorHandlingExample.generateCode()
    let expected = """
var vendingMachine = VendingMachine()
vendingMachine.coinsDeposited = 8
do {
    try buyFavoriteSnack(person: "Alice", vendingMachine: vendingMachine)
    print("Success! Yum.")
} catch VendingMachineError.invalidSelection {
    print("Invalid Selection.")
} catch VendingMachineError.outOfStock {
    print("Out of Stock.")
} catch VendingMachineError.insufficientFunds(let coinsNeeded) {
    print("Insufficient funds. Please insert an additional \\(coinsNeeded) coins.")
} catch {
    print("Unexpected error: \\(error).")
}
"""
    
    #expect(generated.normalize() == expected.normalize())
    
    print("Generated code:")
    print(generated)
  }
} 