import UIKit

public enum Nib: String {
  case BackerDashboardEmptyStateCell
  case BackerDashboardProjectCell
  case CreditCardCell
  case DiscoveryPostcardCell
  case DiscoveryProjectCategoryView
  case FindFriendsCell
  case LoadingBarButtonItemView
  case MessageBannerViewController
  case PaymentMethodsFooterView
  case ProjectPamphletMainCell
  case ProjectPamphletSubpageCell
  case SettingsAccountWarningCell
  case SettingsFormFieldView
  case SettingsFooterView
  case SettingsHeaderView
  case SettingsNewslettersCell
  case SettingsNewslettersTopCell
  case SettingsTableViewCell
  case SettingsTableViewHeader
  case ThanksCategoryCell
  case SettingsNotificationCell
  case SettingsNotificationPickerCell
  case SettingsPrivacySwitchCell
}

extension UITableView {
  public func register(nib: Nib, inBundle bundle: Bundle = .framework) {
    self.register(UINib(nibName: nib.rawValue, bundle: bundle), forCellReuseIdentifier: nib.rawValue)
  }

  public func registerHeaderFooter(nib: Nib, inBundle bundle: Bundle = .framework) {
    self.register(
      UINib(nibName: nib.rawValue, bundle: bundle),
      forHeaderFooterViewReuseIdentifier: nib.rawValue
    )
  }
}

protocol NibLoading {
  associatedtype CustomNibType

  static func fromNib(nib: Nib) -> CustomNibType?
}

extension NibLoading {
  static func fromNib(nib: Nib) -> Self? {
    // swiftformat:disable indent
    guard let view = UINib(nibName: nib.rawValue, bundle: .framework)
      .instantiate(withOwner: self, options: nil)
      .first as? Self else {
        assertionFailure("Nib not found")
        return nil
      }
    // swiftformat:enable indent

    return view
  }

  func view(fromNib nib: Nib) -> UIView? {
    return UINib(nibName: nib.rawValue, bundle: .framework).instantiate(withOwner: self, options: nil).first
      as? UIView
  }
}
