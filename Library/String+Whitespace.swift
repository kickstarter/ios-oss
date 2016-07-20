import Foundation

extension String {
  /**
   Returns a new string with all spaces converted into non-breaking spaces.

   - returns: The new string.
   */
  public func nonBreakingSpaced() -> String {
    return stringByReplacingOccurrencesOfString(" ", withString: "\u{00a0}")
  }

  public func trimmed() -> String {
    return stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
  }
}
