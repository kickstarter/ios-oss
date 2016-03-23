/**
 Used with UIAlertController or by SFSafariViewController
 */
import func Library.localizedString

public enum HelpType {
  case Contact
  case Cookie
  case HowItWorks
  case Privacy
  case Terms

  public static let allValues: [HelpType] = [
    .HowItWorks, .Contact, .Terms, .Privacy, .Cookie
  ]

  public var title: String {
    switch self {
    case .Contact:
    return localizedString(key: "login_tout.help_sheet.contact", defaultValue: "Contact")
    case .Cookie:
      return localizedString(key: "login_tout.help_sheet.cookie", defaultValue: "Cookie Policy")
    case .HowItWorks:
    return localizedString(key: "login_tout.help_sheet.how_it_works", defaultValue: "How Kickstarter Works")
    case .Privacy:
      return localizedString(key: "login_tout.help_sheet.privacy", defaultValue: "Privacy Policy")
    case .Terms:
      return localizedString(key: "login_tout.help_sheet.terms", defaultValue: "Terms of Use")
    }
  }
}
