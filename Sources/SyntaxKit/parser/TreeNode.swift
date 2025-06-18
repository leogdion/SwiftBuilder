//
//  TreeNode.swift
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

internal final class TreeNode: Codable {
  internal let id: Int
  internal var parent: Int?

  internal var text: String
  internal var range = Range(
    startRow: 0, startColumn: 0, endRow: 0, endColumn: 0)
  internal var structure = [StructureProperty]()
  internal var type: SyntaxType
  internal var token: Token?

  init(id: Int, text: String, range: Range, type: SyntaxType) {
    self.id = id
    self.text = text.escapeHTML()
    self.range = range
    self.type = type
  }
}

extension TreeNode: Equatable {
  static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
    lhs.id == rhs.id && lhs.parent == rhs.parent && lhs.text == rhs.text && lhs.range == rhs.range
      && lhs.structure == rhs.structure && lhs.type == rhs.type && lhs.token == rhs.token
  }
}

extension TreeNode: CustomStringConvertible {
  var description: String {
    """
    {
      id: \(id)
      parent: \(String(describing: parent))
      text: \(text)
      range: \(range)
      structure: \(structure)
      type: \(type)
      token: \(String(describing: token))
    }
    """
  }
}

internal struct Range: Codable, Equatable {
  internal let startRow: Int
  internal let startColumn: Int
  internal let endRow: Int
  internal let endColumn: Int
}

extension Range: CustomStringConvertible {
  var description: String {
    """
    {
      startRow: \(startRow)
      startColumn: \(startColumn)
      endRow: \(endRow)
      endColumn: \(endColumn)
    }
    """
  }
}

internal struct StructureProperty: Codable, Equatable {
  internal let name: String
  internal let value: StructureValue?
  internal let ref: String?

  init(name: String, value: StructureValue? = nil, ref: String? = nil) {
    self.name = name.escapeHTML()
    self.value = value
    self.ref = ref?.escapeHTML()
  }
}

extension StructureProperty: CustomStringConvertible {
  var description: String {
    """
    {
      name: \(name)
      value: \(String(describing: value))
      ref: \(String(describing: ref))
    }
    """
  }
}

internal struct StructureValue: Codable, Equatable {
  internal let text: String
  internal let kind: String?

  init(text: String, kind: String? = nil) {
    self.text = text.escapeHTML().replaceHTMLWhitespacesToSymbols()
    self.kind = kind?.escapeHTML()
  }
}

extension StructureValue: CustomStringConvertible {
  var description: String {
    """
    {
      text: \(text)
      kind: \(String(describing: kind))
    }
    """
  }
}

internal enum SyntaxType: String, Codable {
  case decl
  case expr
  case pattern
  case type
  case collection
  case other
}

internal struct Token: Codable, Equatable {
  internal let kind: String
  internal var leadingTrivia: String
  internal var trailingTrivia: String

  init(kind: String, leadingTrivia: String, trailingTrivia: String) {
    self.kind = kind.escapeHTML()
    self.leadingTrivia = leadingTrivia
    self.trailingTrivia = trailingTrivia
  }
}

extension Token: CustomStringConvertible {
  var description: String {
    """
    {
      kind: \(kind)
      leadingTrivia: \(leadingTrivia)
      trailingTrivia: \(trailingTrivia)
    }
    """
  }
}

extension String {
  fileprivate func replaceHTMLWhitespacesToSymbols() -> String {
    self
      .replacingOccurrences(of: "&nbsp;", with: "<span class='whitespace'>␣</span>")
      .replacingOccurrences(of: "<br>", with: "<span class='newline'>↲</span>")
  }
}
