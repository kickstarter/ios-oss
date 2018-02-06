import Foundation

extension String {
  /**
   Returns a truncated string.

   - parameter maxLength: The maximum length to truncate to.
   - parameter suffix: A string to replace the omitted portion with.

     - returns: The truncated string.
   */
  public func truncated(maxLength: Int, suffix: String = "…") -> String {

    guard self.count > maxLength else { return self }

    let advancedBy = maxLength - suffix.count

    guard let index = self.index(self.startIndex, offsetBy: advancedBy, limitedBy: self.endIndex) else {
      return self
    }

    return String(self.prefix(upTo: index)) + suffix
  }
}
