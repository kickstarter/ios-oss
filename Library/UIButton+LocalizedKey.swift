import UIKit

extension UIButton {
  /**
   The key to use for the localized button title in its normal state.
  */
  @IBInspectable
  var normalLocalizedKey: String {
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
  @IBInspectable
  var selectedLocalizedKey: String {
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
  @IBInspectable
  var disabledLocalizedKey: String {
    set(key) {
      self.setTitle(localizedString(key: key, defaultValue: self.titleForState(.Disabled) ?? ""),
        forState: .Disabled)
    }
    get {
      return ""
    }
  }
}
