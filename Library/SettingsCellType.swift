import KsApi
import UIKit

public struct SettingsCellValue {
  public let cellType: SettingsCellTypeProtocol
  public let currency: Currency?
  public let user: User?

  public init(cellType: SettingsCellTypeProtocol, currency: Currency? = nil, user: User? = nil) {
    self.cellType = cellType
    self.currency = currency
    self.user = user
  }
}

public protocol SettingsCellTypeProtocol {
  var accessibilityTraits: UIAccessibilityTraits { get }
  var showArrowImageView: Bool { get }
  var textColor: UIColor { get }
  var title: String { get }
}

public enum SettingsSectionType: Int, CaseIterable {
  case account
  case notificationNewsletters
  case help
  case logout
  case ratingAppVersion

  public static var sectionHeaderHeight: CGFloat {
    return Styles.grid(5)
  }

  public var cellRowsForSection: [SettingsCellType] {
    switch self {
    case .account:
      return [SettingsCellType.account]
    case .notificationNewsletters:
      return [.notifications, .newsletters]
    case .help:
      return [.help]
    case .logout:
      return [SettingsCellType.logout]
    case .ratingAppVersion:
      return [.rateInAppStore]
    }
  }

  public var hasSectionFooter: Bool {
    switch self {
    case .ratingAppVersion:
      return true
    default:
      return false
    }
  }

  public var footerText: String? {
    switch self {
    case .ratingAppVersion:
      let appVersionString = AppEnvironment.current.mainBundle.appVersionString
      return "\(Strings.App_version()) \(appVersionString)"
    default:
      return nil
    }
  }
}

// TODO: When the decision to add the Facebook friends feature back in is confirmed, refer to this PR:
// https://github.com/kickstarter/ios-oss/pull/1655
public enum SettingsCellType: SettingsCellTypeProtocol {
  case account
  case notifications
  case newsletters
  case help
  case logout
  case rateInAppStore
  case findFriends

  public var accessibilityTraits: UIAccessibilityTraits {
    return .button
  }

  public var title: String {
    switch self {
    case .account:
      return Strings.Account()
    case .notifications:
      return Strings.profile_settings_navbar_title_notifications()
    case .newsletters:
      return Strings.profile_settings_newsletter_title()
    case .help:
      return Strings.general_navigation_buttons_help()
    case .logout:
      return Strings.profile_settings_logout_alert_title()
    case .rateInAppStore:
      return Strings.Rate_us_in_the_App_Store()
    case .findFriends:
      return Strings.profile_settings_social_find_friends()
    }
  }

  public var showArrowImageView: Bool {
    switch self {
    case .account, .notifications, .newsletters, .help, .findFriends, .rateInAppStore:
      return true
    default:
      return false
    }
  }

  public var textColor: UIColor {
    switch self {
    case .logout:
      return .ksr_alert
    default:
      return .ksr_support_700
    }
  }
}

public enum HelpSectionType: Int {
  case help
  case privacy

  public static var sectionHeaderHeight: CGFloat {
    return Styles.grid(5)
  }

  public static var allCases: [HelpSectionType] = [.help, .privacy]

  public var cellRowsForSection: [HelpType] {
    switch self {
    case .help:
      return [.helpCenter, .contact]
    case .privacy:
      return [.terms, .privacy, .cookie, .accessibility]
    }
  }
}
