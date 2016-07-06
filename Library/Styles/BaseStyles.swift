import Prelude
import Prelude_UIKit
import UIKit

private let defaultRadius: CGFloat = 3.0

public func baseControllerStyle <VC: UIViewControllerProtocol> () -> (VC -> VC) {
  return VC.lens.view.backgroundColor .~ .ksr_offWhite
}

public func baseTableControllerStyle <TVC: UITableViewControllerProtocol>
  (estimatedRowHeight estimatedRowHeight: CGFloat = 44.0) -> (TVC -> TVC) {
  let style = baseControllerStyle()
    <> TVC.lens.tableView.rowHeight .~ UITableViewAutomaticDimension
    <> TVC.lens.tableView.estimatedRowHeight .~ estimatedRowHeight

  #if os(iOS)
    return style <> TVC.lens.tableView.separatorStyle .~ .None
  #else
    return style
  #endif
}

public func baseTableViewCellStyle <TVC: UITableViewCellProtocol> () -> (TVC -> TVC) {

  return
    (TVC.lens.contentView • UIView.lens.layoutMargins) .~ .init(all: 16.0)
      <> (TVC.lens.contentView • UIView.lens.preservesSuperviewLayoutMargins) .~ false
      <> TVC.lens.layoutMargins .~ .init(all: 0.0)
      <> TVC.lens.preservesSuperviewLayoutMargins .~ false
      <> TVC.lens.selectionStyle .~ .None
}

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
    <> UITextField.lens.backgroundColor .~ .clearColor()
    <> UITextField.lens.borderStyle .~ .None
    <> UITextField.lens.autocapitalizationType .~ .None
    <> UITextField.lens.autocorrectionType .~ .No
    <> UITextField.lens.spellCheckingType .~ .No

public let separatorStyle =
  UIView.lens.backgroundColor .~ .ksr_gray

/**
 - parameter radius: The corner radius. This parameter is optional, and will use a default value if omitted.

 - returns: A view transformer that rounds corners.
 */
public func roundedStyle <V: UIViewProtocol> (cornerRadius radius: CGFloat = defaultRadius) -> (V -> V) {
  return V.lens.layer.masksToBounds .~ true
    <> V.lens.layer.cornerRadius .~ radius
}
