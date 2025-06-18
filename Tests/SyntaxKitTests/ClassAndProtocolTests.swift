import Testing

@testable import SyntaxKit

struct ClassAndProtocolTests {
  @Test func testSimpleProtocol() {
    let vehicleProtocol = Protocol("Vehicle") {
      PropertyRequirement("numberOfWheels", type: "Int", access: .get)
      PropertyRequirement("brand", type: "String", access: .getSet)
      FunctionRequirement("start")
      FunctionRequirement("stop")
      FunctionRequirement("speed", returns: "Int")
    }

    let expected = """
      protocol Vehicle {
          var numberOfWheels: Int { get }
          var brand: String { get set }
          func start()
          func stop()
          func speed() -> Int
      }
      """

    let normalizedGenerated = vehicleProtocol.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

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

  @Test func testEmptyProtocol() {
    let emptyProtocol = Protocol("EmptyProtocol") {}

    let expected = """
      protocol EmptyProtocol {
      }
      """

    let normalizedGenerated = emptyProtocol.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testProtocolWithInheritance() {
    let protocolWithInheritance = Protocol("MyProtocol") {
      PropertyRequirement("value", type: "String", access: .getSet)
    }.inherits("Equatable", "Hashable")

    let expected = """
      protocol MyProtocol: Equatable, Hashable {
          var value: String { get set }
      }
      """

    let normalizedGenerated = protocolWithInheritance.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testFunctionRequirementWithParameters() {
    let protocolWithFunction = Protocol("Calculator") {
      FunctionRequirement("add", returns: "Int") {
        Parameter(name: "a", type: "Int")
        Parameter(name: "b", type: "Int")
      }
    }

    let expected = """
      protocol Calculator {
          func add(a: Int, b: Int) -> Int
      }
      """

    let normalizedGenerated = protocolWithFunction.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testStaticFunctionRequirement() {
    let protocolWithStaticFunction = Protocol("Factory") {
      FunctionRequirement("create", returns: "Self").static()
    }

    let expected = """
      protocol Factory {
          static func create() -> Self
      }
      """

    let normalizedGenerated = protocolWithStaticFunction.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testMutatingFunctionRequirement() {
    let protocolWithMutatingFunction = Protocol("Resettable") {
      FunctionRequirement("reset").mutating()
    }

    let expected = """
      protocol Resettable {
          mutating func reset()
      }
      """

    let normalizedGenerated = protocolWithMutatingFunction.generateCode().normalize()
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
    let genericClass = Class("Container", generics: ["T"]) {
      Variable(.var, name: "value", type: "T")
    }

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
    let multiGenericClass = Class("Pair", generics: ["T", "U"]) {
      Variable(.var, name: "first", type: "T")
      Variable(.var, name: "second", type: "U")
    }

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
    }.inherits("Vehicle", "Codable", "Equatable")

    let expected = """
      class AdvancedVehicle: Vehicle, Codable, Equatable {
          var speed: Int
      }
      """

    let normalizedGenerated = classWithMultipleInheritance.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testClassWithGenericsAndInheritance() {
    let genericClassWithInheritance = Class("GenericContainer", generics: ["T"]) {
      Variable(.var, name: "items", type: "[T]")
    }.inherits("Collection")

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
    let finalGenericClass = Class("FinalGenericClass", generics: ["T"]) {
      Variable(.var, name: "value", type: "T")
    }.inherits("BaseClass").final()

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

  @Test func testPropertyRequirementGetOnly() {
    let propertyReq = PropertyRequirement("readOnlyProperty", type: "String", access: .get)
    let prtcl = Protocol("TestProtocol") {
      propertyReq
    }

    let expected = """
      protocol TestProtocol {
          var readOnlyProperty: String { get }
      }
      """

    let normalizedGenerated = prtcl.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testPropertyRequirementGetSet() {
    let propertyReq = PropertyRequirement("readWriteProperty", type: "Int", access: .getSet)
    let prtcl = Protocol("TestProtocol") {
      propertyReq
    }

    let expected = """
      protocol TestProtocol {
          var readWriteProperty: Int { get set }
      }
      """

    let normalizedGenerated = prtcl.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testFunctionRequirementWithDefaultParameters() {
    let functionReq = FunctionRequirement("process", returns: "String") {
      Parameter(name: "input", type: "String")
      Parameter(name: "options", type: "ProcessingOptions", defaultValue: "ProcessingOptions()")
    }
    let prtcl = Protocol("TestProtocol") {
      functionReq
    }

    let expected = """
      protocol TestProtocol {
          func process(input: String, options: ProcessingOptions = ProcessingOptions()) -> String
      }
      """

    let normalizedGenerated = prtcl.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }

  @Test func testComplexProtocolWithMixedRequirements() {
    let complexProtocol = Protocol("ComplexProtocol") {
      PropertyRequirement("id", type: "UUID", access: .get)
      PropertyRequirement("name", type: "String", access: .getSet)
      FunctionRequirement("initialize").mutating()
      FunctionRequirement("process", returns: "Result") {
        Parameter(name: "input", type: "Data")
      }
      FunctionRequirement("factory", returns: "Self").static()
    }.inherits("Identifiable")

    let expected = """
      protocol ComplexProtocol: Identifiable {
          var id: UUID { get }
          var name: String { get set }
          mutating func initialize()
          func process(input: Data) -> Result
          static func factory() -> Self
      }
      """

    let normalizedGenerated = complexProtocol.generateCode().normalize()
    let normalizedExpected = expected.normalize()
    #expect(normalizedGenerated == normalizedExpected)
  }
}