import UIKit

extension UITraitCollection {
  static let allCases: [UITraitCollection] = [
    UITraitCollection(preferredContentSizeCategory: .extraSmall),
    UITraitCollection(preferredContentSizeCategory: .small),
    UITraitCollection(preferredContentSizeCategory: .medium),
    UITraitCollection(preferredContentSizeCategory: .large),
    UITraitCollection(preferredContentSizeCategory: .extraLarge),
    UITraitCollection(preferredContentSizeCategory: .extraExtraLarge),
    UITraitCollection(preferredContentSizeCategory: .extraExtraExtraLarge),
    UITraitCollection(preferredContentSizeCategory: .accessibilityMedium),
    UITraitCollection(preferredContentSizeCategory: .accessibilityLarge),
    UITraitCollection(preferredContentSizeCategory: .accessibilityExtraLarge),
    UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraLarge),
    UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
  ]
}
