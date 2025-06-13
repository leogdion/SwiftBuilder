# SwiftBuilder

SwiftBuilder is a Swift package that allows developers to build Swift code using result builders. It provides a declarative way to generate Swift code structures using SwiftSyntax.

## Installation

Add SwiftBuilder to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftBuilder.git", from: "1.0.0")
]
```

## Usage

SwiftBuilder provides a set of result builders that allow you to create Swift code structures in a declarative way. Here's an example:

```swift
import SwiftBuilder

let code = Struct("BlackjackCard") {
    Enum("Suit") {
        Case("spades").equals("♠")
        Case("hearts").equals("♡")
        Case("diamonds").equals("♢")
        Case("clubs").equals("♣")
    }
    .inherits("Character")
    .comment("nested Suit enumeration")
}

let generatedCode = code.generateCode()
```

This will generate the following Swift code:

```swift
struct BlackjackCard {
    // nested Suit enumeration
    enum Suit: Character {
        case spades = "♠"
        case hearts = "♡"
        case diamonds = "♢"
        case clubs = "♣"
    }
}
```

## Features

- Create structs, enums, and cases using result builders
- Add inheritance and comments to your code structures
- Generate formatted Swift code using SwiftSyntax
- Type-safe code generation

## Requirements

- Swift 5.9+
- macOS 13.0+

## License

This project is licensed under the MIT License - see the LICENSE file for details. 