import UIKit.UILabel

public extension UILabel {
  func isTruncated() -> Bool {
    // Determines if Label is truncated
    guard let string = self.text, let font = self.font else { return false }

    let size: CGSize = string.boundingRect(
      with: CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin],
      attributes: [NSAttributedString.Key.font: font],
      context: nil
    ).size

    return size.height > self.bounds.size.height
  }
}
