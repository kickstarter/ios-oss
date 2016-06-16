import class UIKit.UIBarButtonItem
import struct ObjectiveC.Selector

public extension UIBarButtonItem {
  public static func help(target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: localizedString(key: "general.navigation.buttons.help", defaultValue: "Help"),
      style: .Plain,
      target: target,
      action: selector)
    bbi.tintColor = .ksr_green
    return bbi
  }

  public static func close(target: AnyObject?, selector: Selector) -> UIBarButtonItem {
    let bbi = UIBarButtonItem(
      title: localizedString(key: "general.navigation.buttons.close", defaultValue: "Close"),
      style: .Plain,
      target: target,
      action: selector)
    bbi.tintColor = .ksr_green
    return bbi
  }
}
