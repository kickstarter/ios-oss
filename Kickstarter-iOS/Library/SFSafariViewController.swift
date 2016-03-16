import class SafariServices.SFSafariViewController
import class Foundation.NSURL

public extension SFSafariViewController {
  public static func help(helptype: HelpType, baseURL: NSURL) -> SFSafariViewController {
    let path: String
    switch helptype {
    case .Terms:
      path = "terms-of-use"
    case .Privacy:
      path = "privacy"
    case .HowItWorks:
      path = "about"
    case .Cookie:
      path = "cookies"
    default:
      path = ""
    }

    let url = baseURL.URLByAppendingPathComponent(path)

    return SFSafariViewController(URL: url)
  }
}
