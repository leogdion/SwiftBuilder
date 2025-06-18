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

/// A Swift `let` or `var` declaration with an explicit type.
public struct Variable: CodeBlock {
  private let kind: VariableKind
  private let name: String
  private let type: String
  private let defaultValue: String?
  private var isStatic: Bool = false

  /// Creates a `let` or `var` declaration with an explicit type.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - type: The type of the variable.
  ///   - defaultValue: The initial value of the variable, if any.
  public init(_ kind: VariableKind, name: String, type: String, equals defaultValue: String? = nil)
  {
    self.kind = kind
    self.name = name
    self.type = type
    self.defaultValue = defaultValue
  }
  
  /// Creates a `let` or `var` declaration with a literal value.
  /// - Parameters:
  ///   - kind: The kind of variable, either ``VariableKind/let`` or ``VariableKind/var``.
  ///   - name: The name of the variable.
  ///   - value: A literal value that conforms to ``LiteralValue``.
  public init<T: LiteralValue>(_ kind: VariableKind, name: String, equals value: T) {
    self.kind = kind
    self.name = name
    self.type = value.typeName
    self.defaultValue = value.literalString
  }

  /// Marks the variable as `static`.
  /// - Returns: A copy of the variable marked as `static`.
  public func `static`() -> Self {
    var copy = self
    copy.isStatic = true
    return copy
  }

  public var syntax: SyntaxProtocol {
    let bindingKeyword = TokenSyntax.keyword(kind == .let ? .let : .var, trailingTrivia: .space)
    let identifier = TokenSyntax.identifier(name, trailingTrivia: .space)
    let typeAnnotation = TypeAnnotationSyntax(
      colon: .colonToken(leadingTrivia: .space, trailingTrivia: .space),
      type: IdentifierTypeSyntax(name: .identifier(type))
    )

    let initializer = defaultValue.map { value in
      InitializerClauseSyntax(
        equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
        value: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(value)))
      )
    }
    
    var modifiers: DeclModifierListSyntax = []
    if isStatic {
      modifiers = DeclModifierListSyntax([
        DeclModifierSyntax(name: .keyword(.static, trailingTrivia: .space))
      ])
    }

    return VariableDeclSyntax(
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
}
