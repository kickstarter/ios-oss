import class UIKit.UIButton

public extension UIButton {
  /**
   The key to use for the localized button title in its normal state.
   */
  var normalLocalizedKey: String {
    set(key) {
      self.setTitle(localizedString(key: key, defaultValue: self.title(for: []) ?? ""), for: [])
    }
    get {
      return ""
    }
  }

  /**
   The key to use for the localized button title in its selected state.
   */
  var selectedLocalizedKey: String {
    set(key) {
      self.setTitle(
        localizedString(key: key, defaultValue: self.title(for: .selected) ?? ""),
        for: .selected
      )
    }
    get {
      return ""
    }
  }

  /**
   The key to use for the localized button title in its disabled state.
   */
  var disabledLocalizedKey: String {
    set(key) {
      self.setTitle(
        localizedString(key: key, defaultValue: self.title(for: .disabled) ?? ""),
        for: .disabled
      )
    }
    get {
      return ""
    }
  }
}
