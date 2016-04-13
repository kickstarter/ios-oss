import class UIKit.UILabel

public extension UILabel {
  /**
   Replaces `text` of the label with a localized string.

   The locale to be used is derived from the current app environment. If the locale or `key` are not
   recognized, then the label's `text` is left unchanged.
  */
  @IBInspectable
  public var localizedKey: String {
    set (key) {
      self.text = localizedString(key: key, defaultValue: self.text ?? "")
    }
    get {
      return ""
    }
  }

  /**
   A property to denote that the label is not localizable. This is mostly used as an indicator in IB that the
   label is not meant to be localized so to avoid confusion.
  */
  @IBInspectable
  public var notLocalizable: Bool {
    set {}
    get { return false }
  }
}
