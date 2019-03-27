import UIKit

public extension UITraitCollection {
  public func ksr_isAccessibilityCategory() -> Bool {
    let sizeCategory = self.preferredContentSizeCategory

    if #available(iOS 11, *) {
      return sizeCategory.isAccessibilityCategory
    }

    return [
      .accessibilityMedium,
      .accessibilityLarge,
      .accessibilityExtraLarge,
      .accessibilityExtraExtraLarge,
      .accessibilityExtraExtraExtraLarge
      ]
      .contains(sizeCategory)
  }
}
