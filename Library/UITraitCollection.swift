import UIKit

public extension UITraitCollection {
  public func ksr_isAccessibilityCategory() -> Bool {
    let sizeCategory = self.preferredContentSizeCategory

    if #available(iOS 11, *) {
      return sizeCategory.isAccessibilityCategory
    } else {
      return
        sizeCategory == .accessibilityMedium ||
          sizeCategory == .accessibilityLarge ||
          sizeCategory == .accessibilityExtraLarge ||
          sizeCategory == .accessibilityExtraExtraLarge ||
          sizeCategory == .accessibilityExtraExtraExtraLarge
    }
  }
}
