import SwiftSyntax

public extension Trivia {
    /// Extract comment strings (line comments, doc comments, block comments) from the trivia collection.
    var comments: [String] {
        compactMap { piece in
            switch piece {
            case .lineComment(let text),
                 .blockComment(let text),
                 .docLineComment(let text),
                 .docBlockComment(let text):
                return text
            default:
                return nil
            }
        }
    }

    /// Indicates whether the trivia contains any comments.
    var hasComments: Bool {
        !comments.isEmpty
    }
} 