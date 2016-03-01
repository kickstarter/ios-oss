import Foundation
import UIKit

extension UILabel {
  func setHTML(html: String) {
    // Capture a few properties of the label so that they can be restored after setting the attributed text.
    let textColor = self.textColor
    let textAlignment = self.textAlignment

    self.attributedText = html.simpleHtmlAttributedString(font: self.font)

    // restore properties
    self.textColor = textColor
    self.textAlignment = textAlignment
  }
}
