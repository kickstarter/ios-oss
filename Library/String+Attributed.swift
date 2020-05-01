import Foundation
import UIKit

public func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
  let combined = NSMutableAttributedString()
  combined.append(left)
  combined.append(right)
  return NSMutableAttributedString(attributedString: combined)
}

public extension String {
  func attributed(
    with font: UIFont,
    foregroundColor: UIColor,
    attributes: [NSAttributedString.Key: Any],
    bolding strings: [String]
  ) -> NSAttributedString {
    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: self)
    let fullRange = (self as NSString).localizedStandardRange(of: self)

    let regularFontAttributes = [
      NSAttributedString.Key.font: font,
      NSAttributedString.Key.foregroundColor: foregroundColor
    ]
    .withAllValuesFrom(attributes)

    attributedString.addAttributes(regularFontAttributes, range: fullRange)

    let boldFontAttribute = [NSAttributedString.Key.font: font.bolded]

    for string in strings {
      attributedString.addAttributes(
        boldFontAttribute,
        range: (self as NSString).localizedStandardRange(of: string)
      )
    }

    return attributedString
  }
}
