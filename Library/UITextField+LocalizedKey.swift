import class UIKit.UITextField

public extension UITextField {
  /**
   Replaces `placeholder` of the textfield with a localized string.

   The locale to be used is derived from the current app environment. If the locale or `key` are not
   recognized, then the textfield's `placeholder` is left unchanged.
   */
  @IBInspectable
  public var localizedKey: String {
    set (key) {
      self.placeholder = localizedString(key: key, defaultValue: self.placeholder ?? "")
    }
    get {
      return ""
    }
  }
}
