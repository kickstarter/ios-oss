import Foundation
import UIKit

extension Array where Element == TextStyleType {
  var prefix: String {
    if self.contains(.list) {
      return "\u{2022} "
    }
    return ""
  }

  var attributes: [NSAttributedString.Key: Any] {
    var attributes = [NSAttributedString.Key: Any]()

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 5

    var fontSize: CGFloat = 0
    var fontTraits = [UIFontDescriptor.SymbolicTraits]()

    for style in self {
      fontSize = style.fontSize > fontSize ? style.fontSize : fontSize
      if let trait = style.fontTrait {
        fontTraits.append(trait)
      }

      attributes.merge(style.customAttributes) { _, new in new }

      paragraphStyle.alignment = style.textAlignment
    }

    let font = UIFont.systemFont(ofSize: fontSize)
    if let fontDescriptor = font.fontDescriptor
      .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(fontTraits)) {
      attributes[NSAttributedString.Key.font] = UIFont(descriptor: fontDescriptor, size: fontSize)
    }

    attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle

    return attributes
  }
}
