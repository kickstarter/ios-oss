import KsApi
import UIKit

public struct SettingsCurrencyCellValue {
  public let cellType: SettingsCellTypeProtocol
  public let currency: Currency?

  public init(cellType: SettingsCellTypeProtocol, currency: Currency?) {
    self.cellType = cellType
    self.currency = currency
  }
}

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
  var description: String? { get }
  var hideDescriptionLabel: Bool { get }
  var showArrowImageView: Bool { get }
  var textColor: UIColor { get }
  var detailTextColor: UIColor { get }
  var title: String { get }
}

public enum SettingsSectionType: Int, CaseIterable {
  case account
  case notificationNewsletters
  case help
  case findFriends
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
    case .findFriends:
      return [.findFriends]
    case .logout:
      return [SettingsCellType.logout]
    case .ratingAppVersion:
      return [.rateInAppStore, .appVersion]
    }
  }
}

public enum SettingsCellType: SettingsCellTypeProtocol {
  case account
  case notifications
  case newsletters
  case help
  case logout
  case rateInAppStore
  case appVersion
  case findFriends

  public var accessibilityTraits: UIAccessibilityTraits {
    switch self {

    case .appVersion:
      return .none
    default:
      return .button
    }
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
    case .appVersion:
      return Strings.App_version()
    case .findFriends:
      return Strings.profile_settings_social_find_friends()
    }
  }

  public var description: String? {
    switch self {
    case .appVersion:
      return SettingsCellType.appVersionString
    default:
      return nil
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
      return .ksr_red_400
    default:
      return .ksr_soft_black
    }
  }

  public var detailTextColor: UIColor {
    return .ksr_text_dark_grey_400
  }

  public var hideDescriptionLabel: Bool {
    switch self {
    case .appVersion:
      return false
    default:
      return true
    }
  }

  private static var appVersionString: String {
    let versionString = AppEnvironment.current.mainBundle.shortVersionString
    let build = AppEnvironment.current.mainBundle.isRelease
      ? ""
      : " #\(AppEnvironment.current.mainBundle.version)"
    return "\(versionString)\(build)"
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
      return [.terms, .privacy, .cookie]
    }
  }
}
