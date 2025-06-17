import Foundation

// MARK: - Single Line Comments
// This is a basic single-line comment
// You can use it for quick notes or explanations

// MARK: - Multi-line Comments
/*
 This is a multi-line comment
 It can span multiple lines
 Useful for longer explanations
 */

// MARK: - Documentation Comments
/// A simple calculator that performs basic arithmetic operations
///
/// This class provides methods for addition, subtraction, multiplication,
/// and division. It also includes error handling for division by zero.
///
/// Example usage:
/// ```swift
/// let calc = Calculator()
/// let sum = calc.add(5, 3) // Returns 8
/// ```
class Calculator {
    /// Adds two numbers together
    /// - Parameters:
    ///   - a: The first number
    ///   - b: The second number
    /// - Returns: The sum of the two numbers
    func add(_ a: Int, _ b: Int) -> Int {
        a + b
    }

    /// Subtracts the second number from the first
    /// - Parameters:
    ///   - a: The number to subtract from
    ///   - b: The number to subtract
    /// - Returns: The difference between the two numbers
    func subtract(_ a: Int, _ b: Int) -> Int {
        a - b
    }

    /// Multiplies two numbers
    /// - Parameters:
    ///   - a: The first number
    ///   - b: The second number
    /// - Returns: The product of the two numbers
    func multiply(_ a: Int, _ b: Int) -> Int {
        a * b
    }

    /// Divides the first number by the second
    /// - Parameters:
    ///   - a: The dividend
    ///   - b: The divisor
    /// - Returns: The quotient of the division
    /// - Throws: `CalculatorError.divisionByZero` if the divisor is zero
    func divide(_ a: Int, _ b: Int) throws -> Double {
        guard b != 0 else {
            throw CalculatorError.divisionByZero
        }
        return Double(a) / Double(b)
    }
}

// MARK: - Error Types
/// Errors that can occur during calculator operations
enum CalculatorError: Error {
    /// Thrown when attempting to divide by zero
    case divisionByZero
}

// MARK: - TODO Comments
// TODO: Add support for decimal numbers
// TODO: Implement square root function
// TODO: Add unit tests

// MARK: - FIXME Comments
// FIXME: Handle negative numbers in division
// FIXME: Add input validation

// MARK: - MARK Comments
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods

// MARK: - Section Comments
// ======================
// Section: Configuration
// ======================

// MARK: - Code Organization Comments
// Group: Math Operations
// Category: Arithmetic
// Module: Calculator

// MARK: - Usage Example
let calculator = Calculator()

// Example of using documented functions
do {
    let sum = calculator.add(10, 5)
    print("Sum: \(sum)")  // Prints: Sum: 15

    let difference = calculator.subtract(10, 5)
    print("Difference: \(difference)")  // Prints: Difference: 5

    let product = calculator.multiply(10, 5)
    print("Product: \(product)")  // Prints: Product: 50

    let quotient = try calculator.divide(10, 5)
    print("Quotient: \(quotient)")  // Prints: Quotient: 2.0

    // This will throw an error
    let error = try calculator.divide(10, 0)
} catch CalculatorError.divisionByZero {
    print("Error: Division by zero is not allowed")
}
