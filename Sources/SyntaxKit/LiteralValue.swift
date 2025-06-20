//
//  LiteralValue.swift
//  SyntaxKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

/// A protocol for types that can be represented as literal values in Swift code.
public protocol LiteralValue {
  /// The Swift type name for this literal value.
  var typeName: String { get }

  /// Renders this value as a Swift literal string.
  var literalString: String { get }
}

// MARK: - LiteralValue Implementations

/// A tuple value that can be used as a literal.
public struct TupleLiteral: LiteralValue {
  let elements: [Literal?]

  /// Creates a tuple with the given elements.
  /// - Parameter elements: The tuple elements, where `nil` represents a wildcard.
  public init(_ elements: [Literal?]) {
    self.elements = elements
  }

  /// The Swift type name for this tuple.
  public var typeName: String {
    let elementTypes = elements.map { element in
      if let element = element {
        switch element {
        case .integer: return "Int"
        case .float: return "Double"
        case .string: return "String"
        case .boolean: return "Bool"
        case .nil: return "Any?"
        case .ref: return "Any"
        case .tuple: return "Any"
        case .array: return "Any"
        case .dictionary: return "Any"
        }
      } else {
        return "Any"
      }
    }
    return "(\(elementTypes.joined(separator: ", ")))"
  }

  /// Renders this tuple as a Swift literal string.
  public var literalString: String {
    let elementStrings = elements.map { element in
      if let element = element {
        switch element {
        case .integer(let value): return String(value)
        case .float(let value): return String(value)
        case .string(let value): return "\"\(value)\""
        case .boolean(let value): return value ? "true" : "false"
        case .nil: return "nil"
        case .ref(let value): return value
        case .tuple(let tupleElements):
          let tuple = TupleLiteral(tupleElements)
          return tuple.literalString
        case .array(let arrayElements):
          let array = ArrayLiteral(arrayElements)
          return array.literalString
        case .dictionary(let dictionaryElements):
          let dictionary = DictionaryLiteral(dictionaryElements)
          return dictionary.literalString
        }
      } else {
        return "_"
      }
    }
    return "(\(elementStrings.joined(separator: ", ")))"
  }
}

/// An array value that can be used as a literal.
public struct ArrayLiteral: LiteralValue {
  let elements: [Literal]

  /// Creates an array with the given elements.
  /// - Parameter elements: The array elements.
  public init(_ elements: [Literal]) {
    self.elements = elements
  }

  /// The Swift type name for this array.
  public var typeName: String {
    if elements.isEmpty {
      return "[Any]"
    }
    let elementType = elements.first?.typeName ?? "Any"
    return "[\(elementType)]"
  }

  /// Renders this array as a Swift literal string.
  public var literalString: String {
    let elementStrings = elements.map { element in
      switch element {
      case .integer(let value): return String(value)
      case .float(let value): return String(value)
      case .string(let value): return "\"\(value)\""
      case .boolean(let value): return value ? "true" : "false"
      case .nil: return "nil"
      case .ref(let value): return value
      case .tuple(let tupleElements):
        let tuple = TupleLiteral(tupleElements)
        return tuple.literalString
      case .array(let arrayElements):
        let array = ArrayLiteral(arrayElements)
        return array.literalString
      case .dictionary(let dictionaryElements):
        let dictionary = DictionaryLiteral(dictionaryElements)
        return dictionary.literalString
      }
    }
    return "[\(elementStrings.joined(separator: ", "))]"
  }
}

/// A dictionary value that can be used as a literal.
public struct DictionaryLiteral: LiteralValue {
  let elements: [(Literal, Literal)]

  /// Creates a dictionary with the given key-value pairs.
  /// - Parameter elements: The dictionary key-value pairs.
  public init(_ elements: [(Literal, Literal)]) {
    self.elements = elements
  }

  /// The Swift type name for this dictionary.
  public var typeName: String {
    if elements.isEmpty {
      return "[Any: Any]"
    }
    let keyType = elements.first?.0.typeName ?? "Any"
    let valueType = elements.first?.1.typeName ?? "Any"
    return "[\(keyType): \(valueType)]"
  }

  /// Renders this dictionary as a Swift literal string.
  public var literalString: String {
    let elementStrings = elements.map { key, value in
      let keyString: String
      let valueString: String

      switch key {
      case .integer(let key): keyString = String(key)
      case .float(let key): keyString = String(key)
      case .string(let key): keyString = "\"\(key)\""
      case .boolean(let key): keyString = key ? "true" : "false"
      case .nil: keyString = "nil"
      case .ref(let key): keyString = key
      case .tuple(let tupleElements):
        let tuple = TupleLiteral(tupleElements)
        keyString = tuple.literalString
      case .array(let arrayElements):
        let array = ArrayLiteral(arrayElements)
        keyString = array.literalString
      case .dictionary(let dictionaryElements):
        let dictionary = DictionaryLiteral(dictionaryElements)
        keyString = dictionary.literalString
      }

      switch value {
      case .integer(let value): valueString = String(value)
      case .float(let value): valueString = String(value)
      case .string(let value): valueString = "\"\(value)\""
      case .boolean(let value): valueString = value ? "true" : "false"
      case .nil: valueString = "nil"
      case .ref(let value): valueString = value
      case .tuple(let tupleElements):
        let tuple = TupleLiteral(tupleElements)
        valueString = tuple.literalString
      case .array(let arrayElements):
        let array = ArrayLiteral(arrayElements)
        valueString = array.literalString
      case .dictionary(let dictionaryElements):
        let dictionary = DictionaryLiteral(dictionaryElements)
        valueString = dictionary.literalString
      }

      return "\(keyString): \(valueString)"
    }
    return "[\(elementStrings.joined(separator: ", "))]"
  }
}

extension Array: LiteralValue where Element == String {
  /// The Swift type name for an array of strings.
  public var typeName: String { "[String]" }

  /// Renders this array as a Swift literal string with proper escaping.
  public var literalString: String {
    let elements = self.map { element in
      // Escape quotes and newlines
      let escaped =
        element
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\r", with: "\\r")
        .replacingOccurrences(of: "\t", with: "\\t")
      return "\"\(escaped)\""
    }.joined(separator: ", ")
    return "[\(elements)]"
  }
}

extension Dictionary: LiteralValue where Key == Int, Value == String {
  /// The Swift type name for a dictionary mapping integers to strings.
  public var typeName: String { "[Int: String]" }

  /// Renders this dictionary as a Swift literal string with proper escaping.
  public var literalString: String {
    let elements = self.map { key, value in
      // Escape quotes and newlines
      let escaped =
        value
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\r", with: "\\r")
        .replacingOccurrences(of: "\t", with: "\\t")
      return "\(key): \"\(escaped)\""
    }.joined(separator: ", ")
    return "[\(elements)]"
  }
}
