import Foundation

extension String {
  // Non-breaking space character.
  public static let nbsp = " "

  /**
   Returns a new string with all spaces converted into non-breaking spaces.

   - returns: The new string.
   */
  public func nonBreakingSpaced() -> String {
    return self.replacingOccurrences(of: " ", with: "\u{00a0}")
  }

  public func trimmed() -> String {
    return self.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

public func isWhitespacesAndNewlines(_ s: String) -> Bool {
  return s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}
