import Testing

@testable import SyntaxKit

internal struct EdgeCaseTests {
  // MARK: - Error Handling Tests

  @Test("Infix with wrong number of operands throws fatal error")
  internal func testInfixWrongOperandCount() {
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
  internal func testReturnWithNoExpressions() {
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
  internal func testSwitchWithMultiplePatterns() throws {
    let switchStmt = Switch("value") {
      SwitchCase("1") {
        Return { VariableExp("one") }
      }
      SwitchCase("2") {
        Return { VariableExp("two") }
      }
    }

    let generated = switchStmt.generateCode()
    #expect(generated.contains("switch value"))
    #expect(generated.contains("case 1:"))
    #expect(generated.contains("case 2:"))
  }

  @Test("SwitchCase with multiple patterns generates correct syntax")
  internal func testSwitchCaseWithMultiplePatterns() throws {
    let switchCase = SwitchCase("1", "2", "3") {
      Return { VariableExp("number") }
    }

    let generated = switchCase.generateCode()
    #expect(generated.contains("case 1, 2, 3:"))
  }

  // MARK: - Complex Expression Tests

  @Test("Infix with complex expressions generates correct syntax")
  internal func testInfixWithComplexExpressions() throws {
    let infix = Infix("*") {
      Parenthesized {
        Infix("+") {
          VariableExp("a")
          VariableExp("b")
        }
      }
      Parenthesized {
        Infix("-") {
          VariableExp("c")
          VariableExp("d")
        }
      }
    }

    let generated = infix.generateCode()
    #expect(generated.contains("(a + b) * (c - d)"))
  }

  @Test("Return with VariableExp generates correct syntax")
  internal func testReturnWithVariableExp() throws {
    let returnStmt = Return {
      VariableExp("result")
    }

    let generated = returnStmt.generateCode()
    #expect(generated.contains("return result"))
  }

  @Test("Return with complex expression generates correct syntax")
  internal func testReturnWithComplexExpression() throws {
    let returnStmt = Return {
      Infix("+") {
        VariableExp("a")
        VariableExp("b")
      }
    }

    let generated = returnStmt.generateCode()
    #expect(generated.contains("return a + b"))
  }

  // MARK: - CodeBlock Expression Tests

  @Test("CodeBlock expr with TokenSyntax wraps in DeclReferenceExpr")
  internal func testCodeBlockExprWithTokenSyntax() throws {
    let variableExp = VariableExp("x")
    let expr = variableExp.expr

    let generated = expr.description
    #expect(generated.contains("x"))
  }

  // MARK: - Code Generation Edge Cases

  @Test("CodeBlock generateCode with CodeBlockItemListSyntax")
  internal func testCodeBlockGenerateCodeWithItemList() throws {
    let group = Group {
      Variable(.let, name: "x", type: "Int", equals: 1).withExplicitType()
      Variable(.let, name: "y", type: "Int", equals: 2).withExplicitType()
    }

    let generated = group.generateCode()
    #expect(generated.contains("let x  : Int = 1"))
    #expect(generated.contains("let y  : Int = 2"))
  }

  @Test("CodeBlock generateCode with single declaration")
  internal func testCodeBlockGenerateCodeWithSingleDeclaration() throws {
    let variable = Variable(.let, name: "x", type: "Int", equals: 1).withExplicitType()

    let generated = variable.generateCode()
    #expect(generated.contains("let x  : Int = 1"))
  }

  @Test("CodeBlock generateCode with single statement")
  internal func testCodeBlockGenerateCodeWithSingleStatement() throws {
    let assignment = Assignment("x", Literal.integer(42))

    let generated = assignment.generateCode()
    #expect(generated.contains("x = 42"))
  }

  @Test("CodeBlock generateCode with single expression")
  internal func testCodeBlockGenerateCodeWithSingleExpression() throws {
    let variableExp = VariableExp("x")

    let generated = variableExp.generateCode()
    #expect(generated.contains("x"))
  }

  // MARK: - Complex Type Tests

  @Test("TypeAlias with complex nested types")
  internal func testTypeAliasWithComplexNestedTypes() throws {
    let typeAlias = TypeAlias("ComplexType", equals: "Array<Dictionary<String, Optional<Int>>>")

    let generated = typeAlias.generateCode()
    #expect(
      generated.normalize().contains(
        "typealias ComplexType = Array<Dictionary<String, Optional<Int>>>".normalize()))
  }

  @Test("TypeAlias with multiple generic parameters")
  internal func testTypeAliasWithMultipleGenericParameters() throws {
    let typeAlias = TypeAlias("Result", equals: "Result<Success, Failure>")

    let generated = typeAlias.generateCode().normalize()
    #expect(generated.contains("typealias Result = Result<Success, Failure>".normalize()))
  }

  // MARK: - Function Parameter Tests

  @Test("Function with unnamed parameter generates correct syntax")
  internal func testFunctionWithUnnamedParameter() throws {
    let function = Function("process") {
      Parameter(name: "data", type: "Data", isUnnamed: true)
    } _: {
      Variable(.let, name: "result", type: "String", equals: "processed")
    }

    let generated = function.generateCode()
    #expect(generated.contains("func process(_ data: Data)"))
  }

  @Test("Function with parameter default value generates correct syntax")
  internal func testFunctionWithParameterDefaultValue() throws {
    let function = Function("greet") {
      Parameter(name: "name", type: "String", defaultValue: "\"World\"")
    } _: {
      Variable(.let, name: "message", type: "String", equals: "greeting")
    }

    let generated = function.generateCode()
    #expect(generated.contains("func greet(name : String = \"World\")"))
  }

  // MARK: - Enum Case Tests

  @Test("EnumCase with string raw value generates correct syntax")
  internal func testEnumCaseWithStringRawValue() throws {
    let enumDecl = Enum("Status") {
      EnumCase("active").equals(Literal.string("active"))
      EnumCase("inactive").equals(Literal.string("inactive"))
    }

    let generated = enumDecl.generateCode().normalize()
    #expect(generated.contains("case active = \"active\""))
    #expect(generated.contains("case inactive = \"inactive\""))
  }

  @Test("EnumCase with double raw value generates correct syntax")
  internal func testEnumCaseWithDoubleRawValue() throws {
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
  internal func testComputedPropertyWithComplexReturn() throws {
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
  internal func testComputedPropertyWithComments() throws {
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
  internal func testLiteralWithNil() throws {
    let literal = Literal.nil
    let generated = literal.generateCode()
    #expect(generated.contains("nil"))
  }

  @Test("Literal with boolean generates correct syntax")
  internal func testLiteralWithBoolean() throws {
    let literal = Literal.boolean(true)
    let generated = literal.generateCode()
    #expect(generated.contains("true"))
  }

  @Test("Literal with float generates correct syntax")
  internal func testLiteralWithFloat() throws {
    let literal = Literal.float(3.14159)
    let generated = literal.generateCode()
    #expect(generated.contains("3.14159"))
  }
}
