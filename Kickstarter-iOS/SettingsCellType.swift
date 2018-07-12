import UIKit

public protocol SettingsCellTypeProtocol {
  var title: String { get }
  var showArrowImageView: Bool { get }
  var textColor: UIColor { get }
  var hideDescriptionLabel: Bool { get }
}

public enum SettingsSectionType: Int {
  case notificationNewsletters
  case helpPrivacy
  case logout
  case ratingAppVersion

  public var cellRowsForSection: [SettingsCellType] {
    switch self {
    case .notificationNewsletters:
      return [.notifications, .newsletters]
    case .helpPrivacy:
      return [.help, .privacy]
    case .logout:
      return [SettingsCellType.logout]
    case .ratingAppVersion:
      return [.rateInAppStore, .appVersion]
    }
  }

  public static var allCases: [SettingsSectionType] = [.notificationNewsletters,
                                                .helpPrivacy,
                                                .logout,
                                                .ratingAppVersion]
}

public enum SettingsCellType: SettingsCellTypeProtocol {
  case notifications
  case newsletters
  case help
  case privacy
  case logout
  case rateInAppStore
  case appVersion

  public var title: String {
    switch self {
    case .notifications:
      return Strings.profile_settings_navbar_title_notifications()
    case .newsletters:
      return Strings.profile_settings_newsletter_title()
    case .help:
      return Strings.general_navigation_buttons_help()
    case .privacy:
      return Strings.Privacy()
    case .logout:
      return Strings.profile_settings_logout_alert_title()
    case .rateInAppStore:
      return Strings.Rate_us_in_the_App_Store()
    case .appVersion:
      // TODO use translated string here
      return "App version"
    }
  }

  public var showArrowImageView: Bool {
    switch self {
    case .notifications, .newsletters, .help, .privacy, .rateInAppStore:
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
      return .ksr_text_dark_grey_500
    }
  }

  public var hideDescriptionLabel: Bool {
    switch self {
    case .appVersion:
      return false
    default:
      return true
    }
  }
}

public enum HelpSectionType: Int {
  case help
  case privacy

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
