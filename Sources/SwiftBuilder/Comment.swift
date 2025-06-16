import SwiftSyntax
import Foundation

/// Represents a single comment line that can be attached to a syntax node when using `.comment { ... }` in the DSL.
public struct Line {
    public enum Kind {
        /// Regular line comment that starts with `//`.
        case line
        /// Documentation line comment that starts with `///`.
        case doc
    }

    public let kind: Kind
    public let text: String?

    /// Convenience initializer for a regular line comment without specifying the kind explicitly.
    public init(_ text: String) {
        self.kind = .line
        self.text = text
    }

    /// Convenience initialiser. Passing only `kind` will create an empty comment line of that kind.
    ///
    /// Examples:
    /// ```swift
    /// Line("MARK: - Models")              // defaults to `.line` kind
    /// Line(.doc, "Represents a model")    // documentation comment
    /// Line(.doc)                           // empty `///` line
    /// ```
    public init(_ kind: Kind = .line, _ text: String? = nil) {
        self.kind = kind
        self.text = text
    }
}

// MARK: - Internal helpers

private extension Line {
    /// Convert the `Line` to a SwiftSyntax `TriviaPiece`.
    var triviaPiece: TriviaPiece {
        switch kind {
        case .line:
            return .lineComment("// " + (text ?? ""))
        case .doc:
            // Empty doc line should still contain the comment marker so we keep a single `/` if no text.
            if let text = text, !text.isEmpty {
                return .docLineComment("/// " + text)
            } else {
                return .docLineComment("///")
            }
        }
    }
}

// MARK: - Result builder used in trailing closure form

@resultBuilder
public enum CommentBuilderResult {
    public static func buildBlock(_ components: Line...) -> [Line] { components }
}

// MARK: - Wrapper `CodeBlock` that injects leading trivia

private struct CommentedCodeBlock: CodeBlock {
    let base: CodeBlock
    let lines: [Line]

    var syntax: SyntaxProtocol {
        // Shortcut if there are no comment lines
        guard !lines.isEmpty else { return base.syntax }

        let commentTrivia = Trivia(pieces: lines.flatMap { [$0.triviaPiece, TriviaPiece.newlines(1)] })

        // Re-write the first token of the underlying syntax node to prepend the trivia.
        final class FirstTokenRewriter: SyntaxRewriter {
            let newToken: TokenSyntax
            private var replaced = false
            init(newToken: TokenSyntax) { self.newToken = newToken }
            override func visit(_ token: TokenSyntax) -> TokenSyntax {
                if !replaced {
                    replaced = true
                    return newToken
                }
                return token
            }
        }

        guard let firstToken = base.syntax.firstToken(viewMode: .sourceAccurate) else {
            // Fallback – no tokens? return original syntax
            return base.syntax
        }

        let newFirstToken = firstToken.with(\.leadingTrivia, commentTrivia + firstToken.leadingTrivia)

        let rewriter = FirstTokenRewriter(newToken: newFirstToken)
        let rewritten = rewriter.visit(Syntax(base.syntax))
        return rewritten
    }
}

// MARK: - Public DSL surface

public extension CodeBlock {
    /// Attach comments to the current `CodeBlock`.
    /// Usage:
    /// ```swift
    /// Struct("MyStruct") { ... }
    ///   .comment {
    ///       Line("MARK: - Models")
    ///       Line(.doc, "This is a documentation comment")
    ///   }
    /// ```
    /// The provided lines are injected as leading trivia to the declaration produced by this `CodeBlock`.
    func comment(@CommentBuilderResult _ content: () -> [Line]) -> CodeBlock {
        CommentedCodeBlock(base: self, lines: content())
    }
} 