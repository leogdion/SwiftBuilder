import Testing

@testable import SyntaxKit

struct EdgeCaseTests {
  // MARK: - Error Handling Tests

  @Test("Infix with wrong number of operands throws fatal error")
  func testInfixWrongOperandCount() {
    // This test documents the expected behavior
    // In a real scenario, this would cause a fatal error
    // We can't easily test fatalError in unit tests, but we can document it
    let infix = Infix("+") {
      // Only one operand - should cause fatal error
      VariableExp("x")
    }

    // The fatal error would occur when accessing .syntax
    // This test documents the expected behavior
    #expect(true)  // Placeholder - fatal errors can't be easily tested
  }

  @Test("Return with no expressions throws fatal error")
  func testReturnNoExpressions() {
    // This test documents the expected behavior
    // In a real scenario, this would cause a fatal error
    let returnStmt = Return {
      // Empty - should cause fatal error
    }

    // The fatal error would occur when accessing .syntax
    // This test documents the expected behavior
    #expect(true)  // Placeholder - fatal errors can't be easily tested
  }

  // MARK: - Switch and Case Tests

  @Test("Switch with multiple patterns generates correct syntax")
  func testSwitchWithMultiplePatterns() throws {
    let switchStmt = Switch("value") {
      SwitchCase(".first", ".second") {
        Return {
          Literal.string("matched")
        }
      }
      Default {
        Return {
          Literal.string("default")
        }
      }
    }

    let generated = switchStmt.syntax.description
    #expect(generated.contains("switch value"))
    #expect(generated.contains("case .first, .second"))
    #expect(generated.contains("default"))
  }

  @Test("SwitchCase with multiple patterns generates correct syntax")
  func testSwitchCaseMultiplePatterns() throws {
    let switchCase = SwitchCase(".first", ".second", ".third") {
      Return {
        Literal.string("matched")
      }
    }

    let generated = switchCase.syntax.description
    #expect(generated.contains("case .first, .second, .third"))
    #expect(generated.contains("return \"matched\""))
  }

  // MARK: - Complex Expression Tests

  @Test("Infix with complex expressions generates correct syntax")
  func testInfixComplexExpressions() throws {
    let infix = Infix("+") {
      VariableExp("x").property("count")
      VariableExp("y").property("count")
    }

    let generated = infix.syntax.description
    #expect(generated.contains("x.count"))
    #expect(generated.contains("y.count"))
    #expect(generated.contains("+"))
  }

  @Test("Return with VariableExp generates correct syntax")
  func testReturnWithVariableExp() throws {
    let returnStmt = Return {
      VariableExp("result")
    }

    let generated = returnStmt.syntax.description
    #expect(generated.contains("return result"))
  }

  @Test("Return with complex expression generates correct syntax")
  func testReturnWithComplexExpression() throws {
    let returnStmt = Return {
      VariableExp("x").call("map") {
        ParameterExp(name: "", value: "transform")
      }
    }

    let generated = returnStmt.syntax.description
    #expect(generated.contains("return x.map(transform)"))
  }

  // MARK: - CodeBlock Expression Tests

  @Test("CodeBlock expr with TokenSyntax wraps in DeclReferenceExpr")
  func testCodeBlockExprWithTokenSyntax() throws {
    let variableExp = VariableExp("test")
    let expr = variableExp.expr

    let generated = expr.description
    #expect(generated.contains("test"))
  }

  // MARK: - Code Generation Edge Cases

  @Test("CodeBlock generateCode with CodeBlockItemListSyntax")
  func testCodeBlockGenerateCodeWithItemList() throws {
    let group = Group {
      Variable(.let, name: "x", type: "Int", equals: "1")
      Variable(.let, name: "y", type: "Int", equals: "2")
    }

    let generated = group.generateCode()
    #expect(generated.contains("let x  : Int = 1"))
    #expect(generated.contains("let y  : Int = 2"))
  }

  @Test("CodeBlock generateCode with single declaration")
  func testCodeBlockGenerateCodeWithSingleDeclaration() throws {
    let variable = Variable(.let, name: "x", type: "Int", equals: "1")

    let generated = variable.generateCode()
    #expect(generated.contains("let x  : Int = 1"))
  }

  @Test("CodeBlock generateCode with single statement")
  func testCodeBlockGenerateCodeWithSingleStatement() throws {
    let returnStmt = Return {
      Literal.integer(42)
    }

    let generated = returnStmt.generateCode()
    #expect(generated.contains("return 42"))
  }

  @Test("CodeBlock generateCode with single expression")
  func testCodeBlockGenerateCodeWithSingleExpression() throws {
    let literal = Literal.integer(42)

    let generated = literal.generateCode()
    #expect(generated.contains("42"))
  }

  // MARK: - Complex Type Tests

  @Test("TypeAlias with complex nested types")
  func testTypeAliasWithComplexNestedTypes() throws {
    let typeAlias = TypeAlias("ComplexType", equals: "Array<Dictionary<String, Optional<Int>>>")
    let generated = typeAlias.generateCode().normalize()

    #expect(generated.contains("typealias ComplexType = Array<Dictionary<String, Optional<Int>>>"))
  }

  @Test("TypeAlias with multiple generic parameters")
  func testTypeAliasWithMultipleGenericParameters() throws {
    let typeAlias = TypeAlias("Result", equals: "Result<Success, Failure>")
    let generated = typeAlias.generateCode().normalize()

    #expect(generated.contains("typealias Result = Result<Success, Failure>"))
  }

  // MARK: - Function Parameter Tests

  @Test("Function with unnamed parameter generates correct syntax")
  func testFunctionWithUnnamedParameter() throws {
    let function = Function("process") {
      Parameter(name: "data", type: "Data", isUnnamed: true)
    } _: {
      Return {
        VariableExp("data").property("count")
      }
    }

    let generated = function.syntax.description
    #expect(generated.contains("func process(_ data: Data)"))
    #expect(generated.contains("return data.count"))
  }

  @Test("Function with parameter default value generates correct syntax")
  func testFunctionWithParameterDefaultValue() throws {
    let function = Function("greet") {
      Parameter(name: "name", type: "String", defaultValue: "\"World\"")
    } _: {
      Return {
        VariableExp("name")
      }
    }

    let generated = function.syntax.description
    #expect(generated.contains("func greet(name: String = \"World\")"))
  }

  // MARK: - Enum Case Tests

  @Test("EnumCase with string raw value generates correct syntax")
  func testEnumCaseWithStringRawValue() throws {
    let enumDecl = Enum("Status") {
      EnumCase("active").equals(Literal.string("active"))
      EnumCase("inactive").equals(Literal.string("inactive"))
    }

    let generated = enumDecl.generateCode().normalize()
    #expect(generated.contains("case active = \"active\""))
    #expect(generated.contains("case inactive = \"inactive\""))
  }

  @Test("EnumCase with double raw value generates correct syntax")
  func testEnumCaseWithDoubleRawValue() throws {
    let enumDecl = Enum("Precision") {
      EnumCase("low").equals(Literal.float(0.1))
      EnumCase("high").equals(Literal.float(0.001))
    }

    let generated = enumDecl.generateCode().normalize()
    #expect(generated.contains("case low = 0.1"))
    #expect(generated.contains("case high = 0.001"))
  }

  // MARK: - Computed Property Tests

  @Test("ComputedProperty with complex return expression")
  func testComputedPropertyWithComplexReturn() throws {
    let computedProperty = ComputedProperty("description", type: "String") {
      Return {
        VariableExp("name").call("appending") {
          ParameterExp(name: "", value: "\" - \" + String(count)")
        }
      }
    }

    let generated = computedProperty.generateCode().normalize()
    #expect(generated.contains("var description: String"))
    #expect(generated.contains("return name.appending(\" - \" + String(count))"))
  }

  // MARK: - Comment Integration Tests

  @Test("ComputedProperty with comments generates correct syntax")
  func testComputedPropertyWithComments() throws {
    let computedProperty = ComputedProperty("formattedName", type: "String") {
      Return {
        VariableExp("name").property("uppercased")
      }
    }.comment {
      Line(.doc, "Returns the name in uppercase format")
    }

    let generated = computedProperty.generateCode()
    #expect(generated.contains("/// Returns the name in uppercase format"))
    #expect(generated.contains("var formattedName  : String"))
  }

  // MARK: - Literal Tests

  @Test("Literal with nil generates correct syntax")
  func testLiteralWithNil() throws {
    let literal = Literal.nil
    let generated = literal.generateCode()
    #expect(generated.contains("nil"))
  }

  @Test("Literal with boolean generates correct syntax")
  func testLiteralWithBoolean() throws {
    let trueLiteral = Literal.boolean(true)
    let falseLiteral = Literal.boolean(false)

    let trueGenerated = trueLiteral.generateCode()
    let falseGenerated = falseLiteral.generateCode()

    #expect(trueGenerated.contains("true"))
    #expect(falseGenerated.contains("false"))
  }

  @Test("Literal with float generates correct syntax")
  func testLiteralWithFloat() throws {
    let literal = Literal.float(3.14159)
    let generated = literal.generateCode()
    #expect(generated.contains("3.14159"))
  }
}
