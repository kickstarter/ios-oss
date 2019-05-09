import UIKit

public extension UITraitCollection {
  public func ksr_isAccessibilityCategory() -> Bool {
    return self.preferredContentSizeCategory.isAccessibilityCategory
  }
}
