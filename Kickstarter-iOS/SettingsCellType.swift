import Library

public enum SettingsSectionType: Int {
  case notificationNewsletters
  case helpPrivacy
  case logout
  case ratingAppVersion

  var cellRowsForSection: [SettingsCellType] {
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

  static var allCases: [SettingsSectionType] = [.notificationNewsletters, .helpPrivacy, .logout, .ratingAppVersion]
}

public enum SettingsCellType {
  case notifications
  case newsletters
  case help
  case privacy
  case logout
  case rateInAppStore
  case appVersion

  var titleString: String {
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

  var showArrowImageView: Bool {
    switch self {
    case .notifications, .newsletters, .help, .privacy, .rateInAppStore:
      return true
    default:
      return false
    }
  }

  var viewController: UIViewController? {
    switch self {
    case .help:
      return UIViewController()
    case .privacy:
      return UIViewController()
    case .newsletters:
      return UIViewController()
    case .notifications:
      return UIViewController()
    default:
      return nil
    }
  }
}
