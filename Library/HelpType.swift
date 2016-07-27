public enum HelpType {
  case contact
  case cookie
  case faq
  case howItWorks
  case privacy
  case terms

  public var title: String {
    switch self {
    case .contact:
    return Strings.login_tout_help_sheet_contact()
    case .cookie:
      return Strings.login_tout_help_sheet_cookie()
    case .faq:
      return Strings.profile_settings_about_faq()
    case .howItWorks:
    return Strings.login_tout_help_sheet_how_it_works()
    case .privacy:
      return Strings.login_tout_help_sheet_privacy()
    case .terms:
      return Strings.login_tout_help_sheet_terms()
    }
  }

  public var trackingString: String {
    switch self {
    case .contact:
      return "Contact"
    case .cookie:
      return "Cookie Policy"
    case .faq:
      return "FAQ"
    case .howItWorks:
      return "How It Works"
    case .privacy:
      return "Privacy Policy"
    case .terms:
      return "Terms"
    }
  }
}

extension HelpType: Equatable {}
public func == (lhs: HelpType, rhs: HelpType) -> Bool {
  switch (lhs, rhs) {
  case (.contact, .contact), (.cookie, .cookie), (.faq, .faq), (.howItWorks, .howItWorks),
       (.privacy, .privacy), (.terms, .terms):
    return true
  default:
    return false
  }
}
