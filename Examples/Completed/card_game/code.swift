import Foundation

// MARK: - Models
/// Represents a playing card in a standard 52-card deck
///
/// A card has a rank (2-10, J, Q, K, A) and a suit (hearts, diamonds, clubs, spades).
/// Each card can be compared to other cards based on its rank.
struct Card: Comparable {
    /// The rank of the card (2-10, J, Q, K, A)
    let rank: Rank
    /// The suit of the card (hearts, diamonds, clubs, spades)
    let suit: Suit
}

// MARK: - Enums
/// Represents the possible ranks of a playing card
enum Rank: Int, CaseIterable {
    case two = 2
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    case jack
    case queen
    case king
    case ace

    /// Returns a string representation of the rank
    var description: String {
        switch self {
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        default: return "\(rawValue)"
        }
    }
}

/// Represents the four suits in a standard deck of cards
enum Suit: String, CaseIterable {
    case hearts = "♥"
    case diamonds = "♦"
    case clubs = "♣"
    case spades = "♠"
}
