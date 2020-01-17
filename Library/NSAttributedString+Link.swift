import Foundation

public extension NSAttributedString {
  func setAsLink(textToFind: String, linkURL: String) -> NSAttributedString {
    let string = NSMutableAttributedString(attributedString: self)
    let foundRange = string.mutableString.range(of: textToFind)
    if foundRange.location != NSNotFound {
      string.addAttribute(.link, value: linkURL, range: foundRange)
      return string
    }
    return self
  }
}
