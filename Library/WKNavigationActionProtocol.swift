#if os(iOS)
import WebKit

public protocol WKNavigationActionProtocol {
  var navigationType: WKNavigationType { get }
  var request: NSURLRequest { get }
}

extension WKNavigationAction: WKNavigationActionProtocol {}

internal struct MockNavigationAction: WKNavigationActionProtocol {
  internal let navigationType: WKNavigationType
  internal let request: NSURLRequest
}
#endif
