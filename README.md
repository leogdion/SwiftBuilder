# SyntaxKit

SyntaxKit is a Swift package that allows developers to build Swift code using result builders.

[![](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/SyntaxKit/documentation)
[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
![GitHub](https://img.shields.io/github/license/brightdigit/SyntaxKit)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/SyntaxKit)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/SyntaxKit/SyntaxKit.yml?label=actions&logo=github&?branch=main)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSyntaxKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/SyntaxKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSyntaxKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/SyntaxKit)

[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/SyntaxKit)](https://codecov.io/gh/brightdigit/SyntaxKit)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/SyntaxKit)](https://www.codefactor.io/repository/github/brightdigit/SyntaxKit)
[![codebeat badge](https://codebeat.co/badges/ad53f31b-de7a-4579-89db-d94eb57dfcaa)](https://codebeat.co/projects/github-com-brightdigit-SyntaxKit-main)
[![Maintainability](https://qlty.sh/badges/55637213-d307-477e-a710-f9dba332d955/maintainability.svg)](https://qlty.sh/gh/brightdigit/projects/SyntaxKit)

SyntaxKit provides a declarative way to generate Swift code structures using SwiftSyntax.

## Installation

Add SyntaxKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SyntaxKit.git", from: "0.0.1")
]
```

## Usage

SyntaxKit provides a set of result builders that allow you to create Swift code structures in a declarative way. Here's an example:

```swift
import SyntaxKit

let code = Struct("BlackjackCard") {
    Enum("Suit") {
        Case("spades").equals("♠")
        Case("hearts").equals("♡")
        Case("diamonds").equals("♢")
        Case("clubs").equals("♣")
    }
    .inherits("Character")
    .comment{
      Line("nested Suit enumeration")
    }
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

- Swift 6.1+
- macOS 13.0+

## License

This project is licensed under the MIT License - [see the LICENSE file for details.](LICENSE)
