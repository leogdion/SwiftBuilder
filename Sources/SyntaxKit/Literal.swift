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
    }
  }
}

// MARK: - LiteralValue Implementations

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
