import Library
import SafariServices

public extension SFSafariViewController {
  public static func help(helptype: HelpType, baseURL: NSURL) -> SFSafariViewController {
    let path: String
    switch helptype {
    case .Cookie:
      path = "cookies"
    case .FAQ:
      path = "help/faq/kickstarter+basics"
    case .HowItWorks:
      path = "about"
    case .Privacy:
      path = "privacy"
    case .Terms:
      path = "terms-of-use"
    default:
      path = ""
    }

    let url = baseURL.URLByAppendingPathComponent(path)

    return SFSafariViewController(URL: url)
  }
}
