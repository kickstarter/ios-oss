import UIKit

public extension UINavigationItem {
  @IBInspectable
  public var titleLocalizedKey: String {
    set (key) {
      self.title = localizedString(key: key, defaultValue: self.title ?? "")
    }
    get {
      return ""
    }
  }

  #if os(iOS)
  @IBInspectable
  public var promptLocalizedKey: String {
    set (key) {
      self.prompt = localizedString(key: key, defaultValue: self.prompt ?? "")
    }
    get {
      return ""
    }
  }
  #endif
}
