import UIKit

public enum HelpType: SettingsCellTypeProtocol {
  case helpCenter
  case contact
  case howItWorks
  case terms
  case privacy
  case cookie
  case trust

  public var title: String {
    switch self {
    case .helpCenter:
      return Strings.Help_center()
    case .contact:
      return Strings.profile_settings_about_contact()
    case .howItWorks:
      return Strings.profile_settings_about_how_it_works()
    case .terms:
      return Strings.profile_settings_about_terms()
    case .privacy:
      return Strings.profile_settings_about_privacy()
    case .cookie:
      return Strings.profile_settings_about_cookie()
    case .trust:
      return ""
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

  public var description: String? {
    return nil
  }

  public var trackingString: String {
    switch self {
    case .contact:
      return "Contact"
    case .cookie:
      return "Cookie Policy"
    case .helpCenter:
      return "FAQ"
    case .howItWorks:
      return "How It Works"
    case .privacy:
      return "Privacy Policy"
    case .terms:
      return "Terms"
    case .trust:
      return "Trust & Safety"
    }
  }
}

extension HelpType: Equatable {}
public func == (lhs: HelpType, rhs: HelpType) -> Bool {
  switch (lhs, rhs) {
  case (.contact, .contact), (.cookie, .cookie), (.helpCenter, .helpCenter), (.howItWorks, .howItWorks),
       (.privacy, .privacy), (.terms, .terms), (.trust, .trust):
    return true
  default:
    return false
  }
}
