//
//  VariableExp.swift
//  SwiftBuilder
//
//  Created by Leo Dion on 6/15/25.
//
import SwiftSyntax

public struct VariableExp: CodeBlock {
    let name: String
    
    public init(_ name: String) {
        self.name = name
    }
    
    public var syntax: SyntaxProtocol {
       return TokenSyntax.identifier(self.name)
    }
}
