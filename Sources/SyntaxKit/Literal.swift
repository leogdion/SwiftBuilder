//
//  Literal.swift
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

import SwiftSyntax

/// A protocol for types that can be represented as literal values in Swift code.
public protocol LiteralValue {
  /// The Swift type name for this literal value.
  var typeName: String { get }

  /// Renders this value as a Swift literal string.
  var literalString: String { get }
}

/// A literal value.
public enum Literal: CodeBlock {
  /// A string literal.
  case string(String)
  /// A floating-point literal.
  case float(Double)
  /// An integer literal.
  case integer(Int)
  /// A `nil` literal.
  case `nil`
  /// A boolean literal.
  case boolean(Bool)
  /// A reference to a variable or identifier (outputs without quotes).
  case ref(String)
  /// A tuple literal.
  case tuple([Literal?])

  /// The SwiftSyntax representation of this literal.
  public var syntax: SyntaxProtocol {
    switch self {
    case .string(let value):
      return StringLiteralExprSyntax(
        openingQuote: .stringQuoteToken(),
        segments: .init([
          .stringSegment(.init(content: .stringSegment(value)))
        ]),
        closingQuote: .stringQuoteToken()
      )
    case .float(let value):
      return FloatLiteralExprSyntax(literal: .floatLiteral(String(value)))

    case .integer(let value):
      return IntegerLiteralExprSyntax(digits: .integerLiteral(String(value)))
    case .nil:
      return NilLiteralExprSyntax(nilKeyword: .keyword(.nil))
    case .boolean(let value):
      return BooleanLiteralExprSyntax(literal: value ? .keyword(.true) : .keyword(.false))
    case .ref(let value):
      return DeclReferenceExprSyntax(baseName: .identifier(value))
    case .tuple(let elements):
      let tupleElements = TupleExprElementListSyntax(
        elements.enumerated().map { index, element in
          let elementExpr: ExprSyntax
          if let element = element {
            elementExpr =
              element.syntax.as(ExprSyntax.self)
              ?? ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier("")))
          } else {
            // Wildcard pattern - use underscore
            elementExpr = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier("_")))
          }
          return TupleExprElementSyntax(
            label: nil,
            colon: nil,
            expression: elementExpr,
            trailingComma: index < elements.count - 1 ? .commaToken(trailingTrivia: .space) : nil
          )
        }
      )
      return TupleExprSyntax(
        leftParen: .leftParenToken(),
        elements: tupleElements,
        rightParen: .rightParenToken()
      )
    }
  }
}

// MARK: - LiteralValue Implementations

/// A tuple value that can be used as a literal.
public struct TupleLiteral: LiteralValue {
  private let elements: [Literal?]

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
        }
      } else {
        return "_"
      }
    }
    return "(\(elementStrings.joined(separator: ", ")))"
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

// MARK: - Convenience Methods

extension Literal {
  /// Creates a tuple literal from an array of optional literals (for patterns with wildcards).
  public static func tuplePattern(_ elements: [Literal?]) -> Literal {
    .tuple(elements)
  }

  /// Creates an integer literal.
  public static func int(_ value: Int) -> Literal {
    .integer(value)
  }

  /// Converts a Literal.tuple to a TupleLiteral for use in Variable declarations.
  public var asTupleLiteral: TupleLiteral? {
    switch self {
    case .tuple(let elements):
      return TupleLiteral(elements)
    default:
      return nil
    }
  }
}
