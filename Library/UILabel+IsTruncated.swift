import UIKit.UILabel

public extension UILabel {

  public func isTruncated() -> Bool {
    // Determines if Label is truncated
    guard let string = self.text else { return false }

    let size: CGSize = string.boundingRect(
      with: CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin],
      attributes: [NSFontAttributeName: self.font],
      context: nil
      ).size

    return size.height > self.bounds.size.height
  }
}
