import Foundation

public extension String {
  // Non-breaking space character.
   static let nbsp = "\u{00A0}"

  /**
   Returns a new string with all spaces converted into non-breaking spaces.

   - returns: The new string.
   */
 func nonBreakingSpaced() -> String {
    return self.replacingOccurrences(of: " ", with: "\u{00a0}")
  }

   func trimmed() -> String {
    return self.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

 func isWhitespacesAndNewlines(_ s: String) -> Bool {
  return s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}
