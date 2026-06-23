import WebKit

/// A snapshot of the values we need from a `WKNavigationResponse`
/// when deciding how the web view should handle a response.
public struct WKNavigationResponseData {
  public let canShowMIMEType: Bool
  public let response: URLResponse

  public init(navigationResponse: WKNavigationResponse) {
    self.canShowMIMEType = navigationResponse.canShowMIMEType
    self.response = navigationResponse.response
  }

  internal init(canShowMIMEType: Bool, response: URLResponse) {
    self.canShowMIMEType = canShowMIMEType
    self.response = response
  }
}
