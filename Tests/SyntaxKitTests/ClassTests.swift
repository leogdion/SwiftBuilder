import Testing

@testable import SyntaxKit

struct ClassTests {
  @Test func testClassWithInheritance() {
    let carClass = Class("Car") {
      Variable(.var, name: "brand", type: "String")
      Variable(.var, name: "numberOfWheels", type: "Int")
    }.inherits("Vehicle")

    let expected = """
      class Car: Vehicle {
          var brand: String
          var numberOfWheels: Int
      }
      """

    let normalizedGenerated = carClass.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testEmptyClass() {
    let emptyClass = Class("EmptyClass") {}

    let expected = """
      class EmptyClass {
      }
      """

    let normalizedGenerated = emptyClass.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testClassWithGenerics() {
    let genericClass = Class("Container") {
      Variable(.var, name: "value", type: "T")
    }.generic("T")

    let expected = """
      class Container<T> {
          var value: T
      }
      """

    let normalizedGenerated = genericClass.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testClassWithMultipleGenerics() {
    let multiGenericClass = Class("Pair") {
      Variable(.var, name: "first", type: "T")
      Variable(.var, name: "second", type: "U")
    }.generic("T", "U")

    let expected = """
      class Pair<T, U> {
          var first: T
          var second: U
      }
      """

    let normalizedGenerated = multiGenericClass.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testFinalClass() {
    let finalClass = Class("FinalClass") {
      Variable(.var, name: "value", type: "String")
    }.final()

    let expected = """
      final class FinalClass {
          var value: String
      }
      """

    let normalizedGenerated = finalClass.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testClassWithMultipleInheritance() {
    let classWithMultipleInheritance = Class("AdvancedVehicle") {
      Variable(.var, name: "speed", type: "Int")
    }.inherits("Vehicle")

    let expected = """
      class AdvancedVehicle: Vehicle {
          var speed: Int
      }
      """

    let normalizedGenerated = classWithMultipleInheritance.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testClassWithGenericsAndInheritance() {
    let genericClassWithInheritance = Class("GenericContainer") {
      Variable(.var, name: "items", type: "[T]")
    }.generic("T").inherits("Collection")

    let expected = """
      class GenericContainer<T>: Collection {
          var items: [T]
      }
      """

    let normalizedGenerated = genericClassWithInheritance.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testFinalClassWithInheritanceAndGenerics() {
    let finalGenericClass = Class("FinalGenericClass") {
      Variable(.var, name: "value", type: "T")
    }.generic("T").inherits("BaseClass").final()

    let expected = """
      final class FinalGenericClass<T>: BaseClass {
          var value: T
      }
      """

    let normalizedGenerated = finalGenericClass.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testClassWithFunctions() {
    let classWithFunctions = Class("Calculator") {
      Function("add", returns: "Int") {
        Parameter(name: "a", type: "Int")
        Parameter(name: "b", type: "Int")
      } _: {
        Return {
          VariableExp("a + b")
        }
      }
    }

    let expected = """
      class Calculator {
          func add(a: Int, b: Int) -> Int {
              return a + b
          }
      }
      """

    let normalizedGenerated = classWithFunctions.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }
}
