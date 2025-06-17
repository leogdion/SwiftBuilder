import Foundation

extension String {
  func normalize() -> String {
    self
      .replacingOccurrences(of: "//.*$", with: "", options: .regularExpression)
      .replacingOccurrences(of: "\\s*:\\s*", with: ": ", options: .regularExpression)
      .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
