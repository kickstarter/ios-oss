import class UIKit.UILabel

public extension UILabel {
  public func setHTML(_ html: String) {
    // Capture a few properties of the label so that they can be restored after setting the attributed text.
    let textColor = self.textColor
    let textAlignment = self.textAlignment

    self.attributedText = html.simpleHtmlAttributedString(font: self.font)

    // restore properties
    self.textColor = textColor
    self.textAlignment = textAlignment
  }
}
