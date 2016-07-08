import class UIKit.UIBarButtonItem
import struct ObjectiveC.Selector

public extension UIBarButtonItem {
  public static func help(target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: Strings.general_navigation_buttons_help(),
      style: .Plain,
      target: target,
      action: selector)
    bbi.tintColor = .ksr_green(weight: 400)
    return bbi
  }

  public static func close(target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: Strings.general_navigation_buttons_close(),
      style: .Plain,
      target: target,
      action: selector)
    bbi.tintColor = .ksr_green(weight: 400)
    return bbi
  }
}
