import class UIKit.UIButton

public extension UIButton {
  /**
   The key to use for the localized button title in its normal state.
  */
  public var normalLocalizedKey: String {
    set(key) {
      self.setTitle(localizedString(key: key, defaultValue: self.title(for: UIControlState()) ?? ""),
        for: UIControlState())
    }
    get {
      return ""
    }
  }

  /**
   The key to use for the localized button title in its selected state.
   */
  public var selectedLocalizedKey: String {
    set(key) {
      self.setTitle(localizedString(key: key, defaultValue: self.title(for: .selected) ?? ""),
        for: .selected)
    }
    get {
      return ""
    }
  }

  /**
   The key to use for the localized button title in its disabled state.
   */
  public var disabledLocalizedKey: String {
    set(key) {
      self.setTitle(localizedString(key: key, defaultValue: self.title(for: .disabled) ?? ""),
        for: .disabled)
    }
    get {
      return ""
    }
  }
}
