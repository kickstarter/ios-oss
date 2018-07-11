import Library

protocol SettingsCellTypeProtocol {
  var titleString: String { get }
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

  static var allCases: [SettingsSectionType] = [.notificationNewsletters,
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

  public var titleString: String {
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
  case howItWorks
  case privacy

  static var allCases: [HelpSectionType] = [.help, .howItWorks, .privacy]

  public var cellRowsForSection: [HelpCellType] {
    switch self {
    case .help:
      return [.helpCenter, .contact]
    case .howItWorks:
      return [.howItWorks]
    case .privacy:
      return [.termsOfUse, .privacyPolicy, .cookiePolicy]
    }
  }
}

public enum HelpCellType: SettingsCellTypeProtocol {
  case helpCenter
  case contact
  case howItWorks
  case termsOfUse
  case privacyPolicy
  case cookiePolicy

  public var titleString: String {
    switch self {
    case .helpCenter:
      return Strings.Help_center()
    case .contact:
      return Strings.profile_settings_about_contact()
    case .howItWorks:
      return Strings.profile_settings_about_how_it_works()
    case .termsOfUse:
      return Strings.profile_settings_about_terms()
    case .privacyPolicy:
      return Strings.profile_settings_about_privacy()
    case .cookiePolicy:
      return Strings.profile_settings_about_cookie()
    }
  }

  public var showArrowImageView: Bool {
    switch self {
    case .contact:
      return true
    default:
      return false
    }
  }

  public var textColor: UIColor {
    return .ksr_text_dark_grey_500
  }

  public var hideDescriptionLabel: Bool {
    return true
  }
}
