import class SafariServices.SFSafariViewController
import class Foundation.NSURL
import struct KsApi.ServerConfig

public extension SFSafariViewController {
  public static func help(helptype: HelpType) -> SFSafariViewController {
    var path = ""
    switch helptype {
    case .Terms:
      path = "terms-of-use"
    case .Privacy:
      path = "privacy"
    case .HowItWorks:
      path = "about"
    case .Cookie:
      path = "cookies"
    default: ()
    }

    let url = ServerConfig.production.webBaseUrl.URLByAppendingPathComponent(path)

    return SFSafariViewController(URL: url)
  }
}
