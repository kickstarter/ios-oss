import class UIKit.UIBarButtonItem
import struct ObjectiveC.Selector

public extension UIBarButtonItem {
  public static func back(_ target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: "",
      style: .plain,
      target: target,
      action: selector)
    return bbi
  }

  public static func close(_ target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: Strings.general_navigation_buttons_close(),
      style: .plain,
      target: target,
      action: selector)
    bbi.tintColor = .ksr_green_400
    return bbi
  }

  public static func help(_ target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: Strings.general_navigation_buttons_help(),
      style: .plain,
      target: target,
      action: selector)
    bbi.tintColor = .ksr_green_400
    return bbi
  }
}
