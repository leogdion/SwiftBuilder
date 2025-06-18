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
}
