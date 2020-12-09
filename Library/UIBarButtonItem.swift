import struct ObjectiveC.Selector
import class UIKit.UIBarButtonItem

public extension UIBarButtonItem {
  static func back(_ target: AnyObject?, selector: Selector?) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: "",
      style: .plain,
      target: target,
      action: selector
    )
    return bbi
  }

  static func close(_ target: AnyObject?, selector: Selector?) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: Strings.general_navigation_buttons_close(),
      style: .plain,
      target: target,
      action: selector
    )
    bbi.tintColor = .ksr_create_700
    return bbi
  }

  static func help(_ target: AnyObject?, selector: Selector?) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: Strings.general_navigation_buttons_help(),
      style: .plain,
      target: target,
      action: selector
    )
    bbi.tintColor = .ksr_create_700
    return bbi
  }
}
