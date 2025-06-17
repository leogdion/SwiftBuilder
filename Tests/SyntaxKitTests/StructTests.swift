import XCTest

@testable import SyntaxKit

final class StructTests: XCTestCase {
  func normalize(_ code: String) -> String {
    code
      .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression)  // Remove comments
      .replacingOccurrences(of: "public\\s+", with: "", options: .regularExpression)  // Remove public modifier
      .replacingOccurrences(of: "\\s*:\\s*", with: ": ", options: .regularExpression)  // Normalize colon spacing
      .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)  // Normalize whitespace
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func testGenericStruct() {
    let stackStruct = Struct("Stack", generic: "Element") {
      Variable(.var, name: "items", type: "[Element]", equals: "[]")

      Function("push") {
        Parameter(name: "item", type: "Element", isUnnamed: true)
      } _: {
        VariableExp("items").call("append") {
          ParameterExp(name: "", value: "item")
        }
      }.mutating()

      Function("pop", returns: "Element?") {
        Return { VariableExp("items").call("popLast") }
      }.mutating()

      Function("peek", returns: "Element?") {
        Return { VariableExp("items").property("last") }
      }

      ComputedProperty("isEmpty", type: "Bool") {
        Return { VariableExp("items").property("isEmpty") }
      }

      ComputedProperty("count", type: "Int") {
        Return { VariableExp("items").property("count") }
      }
    }

    let expectedCode = """
      struct Stack<Element> {
          var items: [Element] = []

          mutating func push(_ item: Element) {
              items.append(item)
          }

          mutating func pop() -> Element? {
              return items.popLast()
          }

          func peek() -> Element? {
              return items.last
          }

          var isEmpty: Bool {
              return items.isEmpty
          }

          var count: Int {
              return items.count
          }
      }
      """

    let normalizedGenerated = normalize(stackStruct.generateCode())
    let normalizedExpected = normalize(expectedCode)
    XCTAssertEqual(normalizedGenerated, normalizedExpected)
  }

  func testGenericStructWithInheritance() {
    let containerStruct = Struct("Container", generic: "T") {
      Variable(.var, name: "value", type: "T")
    }.inherits("Equatable")

    let expectedCode = """
      struct Container<T>: Equatable {
          var value: T
      }
      """

    let normalizedGenerated = normalize(containerStruct.generateCode())
    let normalizedExpected = normalize(expectedCode)
    XCTAssertEqual(normalizedGenerated, normalizedExpected)
  }

  func testNonGenericStruct() {
    let simpleStruct = Struct("Point") {
      Variable(.var, name: "x", type: "Double")
      Variable(.var, name: "y", type: "Double")
    }

    let expectedCode = """
      struct Point {
          var x: Double
          var y: Double
      }
      """

    let normalizedGenerated = normalize(simpleStruct.generateCode())
    let normalizedExpected = normalize(expectedCode)
    XCTAssertEqual(normalizedGenerated, normalizedExpected)
  }
}
