public enum HelpType {
  case contact
  case cookie
  case faq
  case howItWorks
  case privacy
  case terms
  case trust
  case delete

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
    case .trust:
      return ""
    case .delete:
      return "Delete my Kickstarter Account"
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
    case .trust:
      return "Trust & Safety"
    case .delete:
      return "Delete my Kickstarter Account"
    }
  }
}

extension HelpType: Equatable {}
public func == (lhs: HelpType, rhs: HelpType) -> Bool {
  switch (lhs, rhs) {
  case (.contact, .contact), (.cookie, .cookie), (.faq, .faq), (.howItWorks, .howItWorks),
       (.privacy, .privacy), (.terms, .terms), (.trust, .trust), (.delete, .delete):
    return true
  default:
    return false
  }
}
