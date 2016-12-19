import Foundation

extension String {
  /**
   Returns a truncated string.

   - parameter maxLength: The maximum length to truncate to.
   - parameter suffix: A string to replace the omitted portion with.

   - returns: The truncated string.
   */
  public func truncated(maxLength: Int, suffix: String = "…") -> String {

    let chars = self.characters
    guard chars.count > maxLength else { return self }

    let advancedBy = maxLength - suffix.characters.count
    let str = String(chars.prefix(upTo: chars.index(chars.startIndex, offsetBy: advancedBy, limitedBy: chars.endIndex)!))

    return str + suffix
  }
}
