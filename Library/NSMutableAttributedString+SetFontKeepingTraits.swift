import Foundation
import UIKit

extension NSMutableAttributedString {
  func setFontKeepingTraits(to font: UIFont, color: UIColor? = nil) {
    self.beginEditing()

    self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { value, range, _ in
      guard let currentFont = value as? UIFont, let newFontDescriptor = currentFont.fontDescriptor
        .withFamily(font.familyName)
        .withSymbolicTraits(currentFont.fontDescriptor.symbolicTraits) else { return }

      let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)

      self.removeAttribute(.font, range: range)
      self.addAttribute(.font, value: newFont, range: range)

      if let color = color {
        self.removeAttribute(.foregroundColor, range: range)
        self.addAttribute(.foregroundColor, value: color, range: range)
      }
    }

    self.endEditing()
  }
}
