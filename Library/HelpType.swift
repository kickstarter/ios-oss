public enum HelpType {
  case contact
  case cookie
  case helpCenter
  case howItWorks
  case privacy
  case terms
  case trust

  public var title: String {
    switch self {
    case .contact:
    return Strings.login_tout_help_sheet_contact()
    case .cookie:
      return Strings.login_tout_help_sheet_cookie()
    case .helpCenter:
      return Strings.Help_center()
    case .howItWorks:
    return Strings.login_tout_help_sheet_how_it_works()
    case .privacy:
      return Strings.login_tout_help_sheet_privacy()
    case .terms:
      return Strings.login_tout_help_sheet_terms()
    case .trust:
      return ""
    }
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
