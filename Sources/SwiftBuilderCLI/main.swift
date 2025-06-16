import Foundation
import SwiftBuilder

// Read Swift code from stdin
let code = String(data: FileHandle.standardInput.readDataToEndOfFile(), encoding: .utf8) ?? ""

do {
    // Parse the code using SwiftBuilder
    let response = try SyntaxParser.parse(code: code, options: ["fold"])
    
    // Output the JSON to stdout
    print(response.syntaxJSON)
} catch {
    // If there's an error, output it as JSON
    let errorResponse = ["error": error.localizedDescription]
    if let jsonData = try? JSONSerialization.data(withJSONObject: errorResponse),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
    }
    exit(1)
} 