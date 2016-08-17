import class UIKit.UIButton

public extension UIButton {
  /**
   The key to use for the localized button title in its normal state.
  */
  public var normalLocalizedKey: String {
    set(key) {
      self.setTitle(localizedString(key: key, defaultValue: self.titleForState(.Normal) ?? ""),
        forState: .Normal)
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
      self.setTitle(localizedString(key: key, defaultValue: self.titleForState(.Selected) ?? ""),
        forState: .Selected)
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
      self.setTitle(localizedString(key: key, defaultValue: self.titleForState(.Disabled) ?? ""),
        forState: .Disabled)
    }
    get {
      return ""
    }
  }
}
