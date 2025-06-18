//
//  VariableStaticTests.swift
//  SyntaxKitTests
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Testing

@testable import SyntaxKit

struct VariableStaticTests {
  
  // MARK: - Static Variable Tests
  
  @Test func testStaticVariableWithStringLiteral() {
    let variable = Variable(.let, name: "test", type: "String", equals: "hello").static()
    let generated = variable.generateCode().normalize()
    
    #expect(generated.contains("static let test: String = hello"))
  }
  
  @Test func testStaticVariableWithArrayLiteral() {
    let array: [String] = ["a", "b", "c"]
    let variable = Variable(.let, name: "mappedValues", equals: array).static()
    let generated = variable.generateCode().normalize()
    
    #expect(generated.contains("static let mappedValues: [String] = [\"a\", \"b\", \"c\"]"))
  }
  
  @Test func testStaticVariableWithDictionaryLiteral() {
    let dict: [Int: String] = [1: "a", 2: "b", 3: "c"]
    let variable = Variable(.let, name: "mappedValues", equals: dict).static()
    let generated = variable.generateCode().normalize()
    
    #expect(generated.contains("static let mappedValues: [Int: String]"))
    #expect(generated.contains("1: \"a\""))
    #expect(generated.contains("2: \"b\""))
    #expect(generated.contains("3: \"c\""))
  }
  
  @Test func testStaticVariableWithVar() {
    let variable = Variable(.var, name: "counter", type: "Int", equals: "0").static()
    let generated = variable.generateCode().normalize()
    
    #expect(generated.contains("static var counter: Int = 0"))
  }
  
  // MARK: - Non-Static Variable Tests
  
  @Test func testNonStaticVariableWithLiteral() {
    let array: [String] = ["x", "y", "z"]
    let variable = Variable(.let, name: "values", equals: array)
    let generated = variable.generateCode().normalize()
    
    #expect(generated.contains("let values: [String] = [\"x\", \"y\", \"z\"]"))
    #expect(!generated.contains("static"))
  }
  
  @Test func testNonStaticVariableWithDictionary() {
    let dict: [Int: String] = [10: "ten", 20: "twenty"]
    let variable = Variable(.let, name: "lookup", equals: dict)
    let generated = variable.generateCode().normalize()
    
    #expect(generated.contains("let lookup: [Int: String]"))
    #expect(generated.contains("10: \"ten\""))
    #expect(generated.contains("20: \"twenty\""))
    #expect(!generated.contains("static"))
  }
  
  // MARK: - Static Method Tests
  
  @Test func testStaticMethodReturnsNewInstance() {
    let original = Variable(.let, name: "test", type: "String", equals: "value")
    let staticVersion = original.static()
    
    // Should be different instances
    #expect(original.generateCode() != staticVersion.generateCode())
    
    // Original should not be static
    let originalGenerated = original.generateCode().normalize()
    #expect(!originalGenerated.contains("static"))
    
    // Static version should be static
    let staticGenerated = staticVersion.generateCode().normalize()
    #expect(staticGenerated.contains("static"))
  }
  
  @Test func testStaticMethodPreservesOtherProperties() {
    let original = Variable(.var, name: "test", type: "String", equals: "value")
    let staticVersion = original.static()
    
    let originalGenerated = original.generateCode().normalize()
    let staticGenerated = staticVersion.generateCode().normalize()
    
    // Both should have the same name and value
    #expect(originalGenerated.contains("test"))
    #expect(staticGenerated.contains("test"))
    #expect(originalGenerated.contains("value"))
    #expect(staticGenerated.contains("value"))
    
    // Both should be var
    #expect(originalGenerated.contains("var"))
    #expect(staticGenerated.contains("var"))
  }
  
  // MARK: - Edge Cases
  
  @Test func testEmptyArrayLiteral() {
    let array: [String] = []
    let variable = Variable(.let, name: "empty", equals: array).static()
    let generated = variable.generateCode().normalize()
    
    #expect(generated.contains("static let empty: [String] = []"))
  }
  
  @Test func testEmptyDictionaryLiteral() {
    let dict: [Int: String] = [:]
    let variable = Variable(.let, name: "empty", equals: dict).static()
    let generated = variable.generateCode().normalize()
    
    #expect(generated.contains("static let empty: [Int: String] = []"))
  }
  
  @Test func testMultipleStaticCalls() {
    let variable = Variable(.let, name: "test", type: "String", equals: "value").static().static()
    let generated = variable.generateCode().normalize()
    
    // Should still only have one "static" keyword
    let staticCount = generated.components(separatedBy: "static").count - 1
    #expect(staticCount == 1)
  }
} 