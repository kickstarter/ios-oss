public enum HelpType {
  case Contact
  case Cookie
  case FAQ
  case HowItWorks
  case Privacy
  case Terms

  public var title: String {
    switch self {
    case .Contact:
    return Strings.login_tout_help_sheet_contact()
    case .Cookie:
      return Strings.login_tout_help_sheet_cookie()
    case .FAQ:
      return Strings.profile_settings_about_faq()
    case .HowItWorks:
    return Strings.login_tout_help_sheet_how_it_works()
    case .Privacy:
      return Strings.login_tout_help_sheet_privacy()
    case .Terms:
      return Strings.login_tout_help_sheet_terms()
    }
  }
}

extension HelpType: Equatable {}
public func == (lhs: HelpType, rhs: HelpType) -> Bool {
  switch (lhs, rhs) {
  case (.Contact, .Contact), (.Cookie, .Cookie), (.FAQ, .FAQ), (.HowItWorks, .HowItWorks),
       (.Privacy, .Privacy), (.Terms, .Terms):
    return true
  default:
    return false
  }
}
