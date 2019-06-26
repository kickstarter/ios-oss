import UIKit

public enum HelpType: SettingsCellTypeProtocol, CaseIterable {
  case helpCenter
  case contact
  case howItWorks
  case terms
  case privacy
  case cookie
  case trust

  public var accessibilityTraits: UIAccessibilityTraits {
    switch self {
    case .contact:
      return .button
    default:
      return .link
    }
  }

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
      return false
    default:
      return true
    }
  }

  public var textColor: UIColor {
    return .ksr_soft_black
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

  public func url(withBaseUrl baseUrl: URL) -> URL? {
    switch self {
    case .cookie:
      return baseUrl.appendingPathComponent("cookies")
    case .contact:
      return nil
    case .helpCenter:
      return baseUrl.appendingPathComponent("help")
    case .howItWorks:
      return baseUrl.appendingPathComponent("about")
    case .privacy:
      return baseUrl.appendingPathComponent("privacy")
    case .terms:
      return baseUrl.appendingPathComponent("terms-of-use")
    case .trust:
      return baseUrl.appendingPathComponent("trust")
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
