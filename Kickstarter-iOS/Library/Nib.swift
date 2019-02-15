import UIKit

public enum Nib: String {
  case BackerDashboardEmptyStateCell
  case BackerDashboardProjectCell
  case CreditCardCell
  case DiscoveryPostcardCell
  case DiscoveryProjectCategoryView
  case FindFriendsCell
  case LiveStreamNavTitleView
  case LoadingBarButtonItemView
  case MessageBannerViewController
  case PaymentMethodsFooterView
  case RewardCell
  case SettingsAccountWarningCell
  case SettingsCurrencyCell
  case SettingsCurrencyPickerCell
  case SettingsFormFieldView
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
    self.register(UINib(nibName: nib.rawValue, bundle: bundle),
                  forHeaderFooterViewReuseIdentifier: nib.rawValue)
  }
}

protocol NibLoading {
  associatedtype CustomNibType

  static func fromNib(nib: Nib) -> CustomNibType?
}

extension NibLoading {
  static func fromNib(nib: Nib) -> Self? {
    guard let view = UINib(nibName: nib.rawValue, bundle: .framework)
      .instantiate(withOwner: self, options: nil)
      .first as? Self else {
        assertionFailure("Nib not found")
        return nil
    }

    return view
  }

  func view(fromNib nib: Nib) -> UIView? {
    return UINib(nibName: nib.rawValue, bundle: .framework).instantiate(withOwner: self, options: nil).first
      as? UIView
  }
}
