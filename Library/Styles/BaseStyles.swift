import Prelude
import Prelude_UIKit
import UIKit

private let defaultRadius: CGFloat = 3.0

public let baseControllerStyle = UIViewController.lens.view.backgroundColor .~ .ksr_offWhite

/**
 - parameter radius: The corner radius. This parameter is optional, and will use a default value if omitted.

 - returns: A view transformer that rounds corners, sets background color, and sets border color.
 */
public func cardStyle <V: UIViewProtocol> (cornerRadius radius: CGFloat = defaultRadius) -> (V -> V) {

  return roundedStyle(cornerRadius: radius)
    <> V.lens.layer.borderColor .~ UIColor.ksr_gray.CGColor
    <> V.lens.layer.borderWidth .~ 1.0
    <> V.lens.backgroundColor .~ .ksr_white
}

public let formFieldStyle =
  UITextField.lens.font .~ .ksr_body
    <> UITextField.lens.textColor .~ .ksr_textDefault
    <> UITextField.lens.borderStyle .~ .None
    <> UITextField.lens.autocapitalizationType .~ .None
    <> UITextField.lens.autocorrectionType .~ .No
    <> UITextField.lens.spellCheckingType .~ .No

/**
 - parameter radius: The corner radius. This parameter is optional, and will use a default value if omitted.

 - returns: A view transformer that rounds corners.
 */
public func roundedStyle <V: UIViewProtocol> (cornerRadius radius: CGFloat = defaultRadius) -> (V -> V) {
  return V.lens.layer.masksToBounds .~ true
    <> V.lens.layer.cornerRadius .~ radius
}
