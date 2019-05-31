import Foundation

public func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
  let combined = NSMutableAttributedString()
  combined.append(left)
  combined.append(right)
  return NSMutableAttributedString(attributedString: combined)
}
