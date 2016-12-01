import class UIKit.UIBarButtonItem
import struct ObjectiveC.Selector

public extension UIBarButtonItem {
  public static func back(target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: "",
      style: .Plain,
      target: target,
      action: selector)
    return bbi
  }

  public static func close(target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: Strings.general_navigation_buttons_close(),
      style: .Plain,
      target: target,
      action: selector)
    bbi.tintColor = .ksr_green_400
    return bbi
  }

  public static func help(target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: Strings.general_navigation_buttons_help(),
      style: .Plain,
      target: target,
      action: selector)
    bbi.tintColor = .ksr_green_400
    return bbi
  }
}
