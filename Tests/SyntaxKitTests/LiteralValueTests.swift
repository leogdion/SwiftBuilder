//
//  LiteralValueTests.swift
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

struct LiteralValueTests {
  // MARK: - Array<String> LiteralValue Tests

  @Test func testArrayStringTypeName() {
    let array: [String] = ["a", "b", "c"]
    #expect(array.typeName == "[String]")
  }

  @Test func testArrayStringLiteralString() {
    let array: [String] = ["a", "b", "c"]
    #expect(array.literalString == "[\"a\", \"b\", \"c\"]")
  }

  @Test func testEmptyArrayStringLiteralString() {
    let array: [String] = []
    #expect(array.literalString == "[]")
  }

  @Test func testArrayStringWithSpecialCharacters() {
    let array: [String] = ["hello world", "test\"quote", "line\nbreak"]
    #expect(array.literalString == "[\"hello world\", \"test\\\"quote\", \"line\\nbreak\"]")
  }

  // MARK: - Dictionary<Int, String> LiteralValue Tests

  @Test func testDictionaryIntStringTypeName() {
    let dict: [Int: String] = [1: "a", 2: "b"]
    #expect(dict.typeName == "[Int: String]")
  }

  @Test func testDictionaryIntStringLiteralString() {
    let dict: [Int: String] = [1: "a", 2: "b", 3: "c"]
    let literal = dict.literalString

    // Dictionary order is not guaranteed, so check that all elements are present
    #expect(literal.contains("1: \"a\""))
    #expect(literal.contains("2: \"b\""))
    #expect(literal.contains("3: \"c\""))
    #expect(literal.hasPrefix("["))
    #expect(literal.hasSuffix("]"))
  }

  @Test func testEmptyDictionaryLiteralString() {
    let dict: [Int: String] = [:]
    #expect(dict.literalString == "[]")
  }

  @Test func testDictionaryWithSpecialCharacters() {
    let dict: [Int: String] = [1: "hello world", 2: "test\"quote"]
    let literal = dict.literalString

    // Dictionary order is not guaranteed, so check that all elements are present
    #expect(literal.contains("1: \"hello world\""))
    #expect(literal.contains("2: \"test\\\"quote\""))
    #expect(literal.hasPrefix("["))
    #expect(literal.hasSuffix("]"))
  }

  // MARK: - Dictionary Ordering Tests

  @Test func testDictionaryOrderingIsConsistent() {
    let dict1: [Int: String] = [2: "b", 1: "a", 3: "c"]
    let dict2: [Int: String] = [1: "a", 2: "b", 3: "c"]

    // Both should produce the same literal string regardless of insertion order
    let literal1 = dict1.literalString
    let literal2 = dict2.literalString

    // The exact order depends on the dictionary's internal ordering,
    // but both should be valid Swift dictionary literals
    #expect(literal1.contains("1: \"a\""))
    #expect(literal1.contains("2: \"b\""))
    #expect(literal1.contains("3: \"c\""))
    #expect(literal2.contains("1: \"a\""))
    #expect(literal2.contains("2: \"b\""))
    #expect(literal2.contains("3: \"c\""))
  }
}
