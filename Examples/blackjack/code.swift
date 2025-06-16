import Foundation

struct BlackjackCard {
  // nested Suit enumeration
  enum Suit: Character {
    case spades = "♠"
    case hearts = "♡"
    case diamonds = "♢"
    case clubs = "♣"
  }

  // nested Rank enumeration
  enum Rank: Int {
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

    struct Values {
      let first: Int, second: Int?
    }

    var values: Values {
      switch self {
      case .ace:
        return Values(first: 1, second: 11)
      case .jack, .queen, .king:
        return Values(first: 10, second: nil)
      default:
        return Values(first: self.rawValue, second: nil)
      }
    }
  }

  // BlackjackCard properties and methods
  let rank: Rank
  let suit: Suit
  var description: String {
    var output = "suit is \(suit.rawValue),"
    output += " value is \(rank.values.first)"
    if let second = rank.values.second {
      output += " or \(second)"
    }
    return output
  }
}
