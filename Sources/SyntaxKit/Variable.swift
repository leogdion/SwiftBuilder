//
//  Variable.swift
//  SyntaxKit
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

import SwiftSyntax
import Foundation

/// A Swift `let` or `var` declaration with an explicit type.
public struct Variable: CodeBlock {
  private let kind: VariableKind
  private let name: String
  private let type: String
  private let defaultValue: CodeBlock?
  private var isStatic: Bool = false
  private var attributes: [AttributeInfo] = []
  private var explicitType: Bool = false

  /// Creates a `let` or `var` declaration with an explicit type.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - type: The type of the variable.
  ///   - equals: The initial value expression of the variable, if any.
  ///   - explicitType: Whether the variable has an explicit type.
  public init(
    _ kind: VariableKind, name: String, type: String, equals defaultValue: CodeBlock? = nil,
    explicitType: Bool? = nil
  ) {
    self.kind = kind
    self.name = name
    self.type = type
    self.defaultValue = defaultValue
    if let explicitType = explicitType {
      self.explicitType = explicitType
    } else {
      self.explicitType = defaultValue == nil
    }
  }

  /// Creates a `let` or `var` declaration with an explicit type and string literal value.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - type: The type of the variable.
  ///   - equals: A string literal value.
  ///   - explicitType: Whether the variable has an explicit type.
  public init(
    _ kind: VariableKind, name: String, type: String, equals value: String,
    explicitType: Bool? = nil
  ) {
    self.kind = kind
    self.name = name
    self.type = type
    self.defaultValue = Literal.string(value)
    if let explicitType = explicitType {
      self.explicitType = explicitType
    } else {
      self.explicitType = true
    }
  }

  /// Creates a `let` or `var` declaration with an explicit type and integer literal value.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - type: The type of the variable.
  ///   - equals: An integer literal value.
  ///   - explicitType: Whether the variable has an explicit type.
  public init(
    _ kind: VariableKind, name: String, type: String, equals value: Int,
    explicitType: Bool? = nil
  ) {
    self.kind = kind
    self.name = name
    self.type = type
    self.defaultValue = Literal.integer(value)
    if let explicitType = explicitType {
      self.explicitType = explicitType
    } else {
      self.explicitType = true
    }
  }

  /// Creates a `let` or `var` declaration with an explicit type and boolean literal value.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - type: The type of the variable.
  ///   - equals: A boolean literal value.
  ///   - explicitType: Whether the variable has an explicit type.
  public init(
    _ kind: VariableKind, name: String, type: String, equals value: Bool,
    explicitType: Bool? = nil
  ) {
    self.kind = kind
    self.name = name
    self.type = type
    self.defaultValue = Literal.boolean(value)
    if let explicitType = explicitType {
      self.explicitType = explicitType
    } else {
      self.explicitType = true
    }
  }

  /// Creates a `let` or `var` declaration with an explicit type and double literal value.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - type: The type of the variable.
  ///   - equals: A double literal value.
  ///   - explicitType: Whether the variable has an explicit type.
  public init(
    _ kind: VariableKind, name: String, type: String, equals value: Double,
    explicitType: Bool? = nil
  ) {
    self.kind = kind
    self.name = name
    self.type = type
    self.defaultValue = Literal.float(value)
    if let explicitType = explicitType {
      self.explicitType = explicitType
    } else {
      self.explicitType = true
    }
  }

  /// Creates a `let` or `var` declaration with a literal value.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - equals: A literal value that conforms to ``LiteralValue``.
  public init<T: LiteralValue>(
    _ kind: VariableKind, name: String, equals value: T
  ) {
    self.kind = kind
    self.name = name
    self.type = value.typeName
    if let literal = value as? Literal {
      self.defaultValue = literal
    } else if let tuple = value as? TupleLiteral {
      self.defaultValue = Literal.tuple(tuple.elements)
    } else if let array = value as? ArrayLiteral {
      self.defaultValue = Literal.array(array.elements)
    } else if let dict = value as? DictionaryLiteral {
      self.defaultValue = Literal.dictionary(dict.elements)
    } else if let array = value as? [String] {
      self.defaultValue = Literal.array(array.map { .string($0) })
    } else if let dict = value as? [Int: String] {
      self.defaultValue = Literal.dictionary(dict.map { (.integer($0.key), .string($0.value)) })
    } else {
      fatalError("Variable: Only Literal types are supported for defaultValue. Got: \(T.self)")
    }
    self.explicitType = false
  }

  /// Creates a `let` or `var` declaration with a string literal value.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - equals: A string literal value.
  public init(
    _ kind: VariableKind, name: String, equals value: String
  ) {
    self.kind = kind
    self.name = name
    self.type = "String"
    self.defaultValue = Literal.string(value)
    self.explicitType = false
  }

  /// Creates a `let` or `var` declaration with an integer literal value.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - equals: An integer literal value.
  public init(
    _ kind: VariableKind, name: String, equals value: Int
  ) {
    self.kind = kind
    self.name = name
    self.type = "Int"
    self.defaultValue = Literal.integer(value)
    self.explicitType = false
  }

  /// Creates a `let` or `var` declaration with a boolean literal value.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - equals: A boolean literal value.
  public init(
    _ kind: VariableKind, name: String, equals value: Bool
  ) {
    self.kind = kind
    self.name = name
    self.type = "Bool"
    self.defaultValue = Literal.boolean(value)
    self.explicitType = false
  }

  /// Creates a `let` or `var` declaration with a double literal value.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - equals: A double literal value.
  public init(
    _ kind: VariableKind, name: String, equals value: Double
  ) {
    self.kind = kind
    self.name = name
    self.type = "Double"
    self.defaultValue = Literal.float(value)
    self.explicitType = false
  }

  /// Creates a `let` or `var` declaration with a Literal value.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - equals: A Literal value.
  public init(
    _ kind: VariableKind, name: String, equals value: Literal
  ) {
    self.kind = kind
    self.name = name
    self.type = value.typeName
    self.defaultValue = value
    self.explicitType = false
  }

  /// Creates a `let` or `var` declaration with a value built from a CodeBlock builder closure.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - value: A builder closure that returns a CodeBlock for the initial value.
  ///   - explicitType: Whether the variable has an explicit type.
  public init(
    _ kind: VariableKind,
    name: String,
    @CodeBlockBuilderResult value: () -> [CodeBlock],
    explicitType: Bool? = nil
  ) {
    self.kind = kind
    self.name = name
    self.type = ""
    self.defaultValue = value().first ?? EmptyCodeBlock()
    if let explicitType = explicitType {
      self.explicitType = explicitType
    } else {
      self.explicitType = false
    }
  }

  /// Marks the variable as `static`.
  /// - Returns: A copy of the variable marked as `static`.
  public func `static`() -> Self {
    var copy = self
    copy.isStatic = true
    return copy
  }

  /// Adds an attribute to the variable declaration.
  /// - Parameters:
  ///   - attribute: The attribute name (without the @ symbol).
  ///   - arguments: The arguments for the attribute, if any.
  /// - Returns: A copy of the variable with the attribute added.
  public func attribute(_ attribute: String, arguments: [String] = []) -> Self {
    var copy = self
    copy.attributes.append(AttributeInfo(name: attribute, arguments: arguments))
    return copy
  }

  public func withExplicitType() -> Self {
    var copy = self
    copy.explicitType = true
    return copy
  }

  public var syntax: SyntaxProtocol {
    let bindingKeyword = TokenSyntax.keyword(kind == .let ? .let : .var, trailingTrivia: .space)
    let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
    let typeAnnotation: TypeAnnotationSyntax? =
      (explicitType && !type.isEmpty)
      ? TypeAnnotationSyntax(
        colon: .colonToken(leadingTrivia: .space, trailingTrivia: .space),
        type: IdentifierTypeSyntax(name: .identifier(type))
      ) : nil
    let initializer = defaultValue.map { value in
      let expr: ExprSyntax
      if let exprBlock = value as? ExprCodeBlock {
        expr = exprBlock.exprSyntax
      } else if let exprSyntax = value.syntax.as(ExprSyntax.self) {
        expr = exprSyntax
      } else {
        expr = ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier("")))
      }
      return InitializerClauseSyntax(
        equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
        value: expr
      )
    }
    var modifiers: DeclModifierListSyntax = []
    if isStatic {
      modifiers = DeclModifierListSyntax([
        DeclModifierSyntax(name: .keyword(.static, trailingTrivia: .space))
      ])
    }
    return VariableDeclSyntax(
      attributes: buildAttributeList(from: attributes),
      modifiers: modifiers,
      bindingSpecifier: bindingKeyword,
      bindings: PatternBindingListSyntax([
        PatternBindingSyntax(
          pattern: IdentifierPatternSyntax(identifier: identifier),
          typeAnnotation: typeAnnotation,
          initializer: initializer
        )
      ])
    )
  }

  private func buildAttributeList(from attributes: [AttributeInfo]) -> AttributeListSyntax {
    if attributes.isEmpty {
      return AttributeListSyntax([])
    }

    let attributeElements = attributes.map { attributeInfo in
      let arguments = attributeInfo.arguments

      var leftParen: TokenSyntax?
      var rightParen: TokenSyntax?
      var argumentsSyntax: AttributeSyntax.Arguments?

      if !arguments.isEmpty {
        leftParen = .leftParenToken()
        rightParen = .rightParenToken()

        let argumentList = arguments.map { argument in
          DeclReferenceExprSyntax(baseName: .identifier(argument))
        }

        argumentsSyntax = .argumentList(
          LabeledExprListSyntax(
            argumentList.enumerated().map { index, expr in
              var element = LabeledExprSyntax(expression: ExprSyntax(expr))
              if index < argumentList.count - 1 {
                element = element.with(\.trailingComma, .commaToken(trailingTrivia: .space))
              }
              return element
            }
          )
        )
      }

      return AttributeListSyntax.Element(
        AttributeSyntax(
          atSign: .atSignToken(),
          attributeName: IdentifierTypeSyntax(name: .identifier(attributeInfo.name)),
          leftParen: leftParen,
          arguments: argumentsSyntax,
          rightParen: rightParen
        )
      )
    }

    return AttributeListSyntax(attributeElements)
  }
}
