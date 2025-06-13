import SwiftBuilder

// Example of generating a BlackjackCard struct with a nested Suit enum
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

// Generate and print the code
print(code.generateCode()) 