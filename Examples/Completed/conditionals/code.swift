// Simple if statement
let temperature = 25
if temperature > 30 {
    print("It's hot outside!")
}

// If-else statement
let score = 85
if score >= 90 {
    print("Excellent!")
} else if score >= 80 {
    print("Good job!")
} else if score >= 70 {
    print("Passing")
} else {
    print("Needs improvement")
}

// MARK: - Optional Binding with If

// Using if let for optional binding
let possibleNumber = "123"
if let actualNumber = Int(possibleNumber) {
    print("The string \"\(possibleNumber)\" has an integer value of \(actualNumber)")
} else {
    print("The string \"\(possibleNumber)\" could not be converted to an integer")
}

// Multiple optional bindings
let possibleName: String? = "John"
let possibleAge: Int? = 30
if let name = possibleName, let age = possibleAge {
    print("\(name) is \(age) years old")
}

// MARK: - Guard Statements
func greet(person: [String: String]) {
    guard let name = person["name"] else {
        print("No name provided")
        return
    }
    
    guard let age = person["age"], let ageInt = Int(age) else {
        print("Invalid age provided")
        return
    }
    
    print("Hello \(name), you are \(ageInt) years old")
}

// MARK: - Switch Statements
// Switch with range matching
let approximateCount = 62
let countedThings = "moons orbiting Saturn"
let naturalCount: String
switch approximateCount {
case 0:
    naturalCount = "no"
case 1..<5:
    naturalCount = "a few"
case 5..<12:
    naturalCount = "several"
case 12..<100:
    naturalCount = "dozens of"
case 100..<1000:
    naturalCount = "hundreds of"
default:
    naturalCount = "many"
}
print("There are \(naturalCount) \(countedThings).")