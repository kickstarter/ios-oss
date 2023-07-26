import Foundation
import PerimeterX_SDK

public class PerimeterXClient: NSObject, PerimeterXClientType {
  private let dateType: ApiDateProtocol.Type
  private var policy = PXPolicy()

  public var vid: String? {
    PerimeterX.vid()
  }

  /**
   Custom `HTTPCookie` adding Perimeter X protection to native webviews.
   */
  public lazy var cookie: HTTPCookie? = {
    HTTPCookie(properties: [
      .domain: "www.perimeterx.com", // Change according to the domain the webview will use
      .path: "/",
      .name: "_pxmvid",
      .value: self.vid ?? "",
      .expires: self.dateType.init(timeIntervalSinceNow: 3_600).date
    ])
  }()

  public init(
    dateType: ApiDateProtocol.Type = Date.self
  ) {
    self.dateType = dateType

    super.init()
  }

  public func headers() -> [String: String] {
    return PerimeterX.headersForURLRequest() ?? [:]
  }

  public func start(policyDomains: Set<String>) {
    self.policy.set(domains: policyDomains, forAppId: Secrets.PerimeterX.appId)

    try? PerimeterX.start(appId: Secrets.PerimeterX.appId, delegate: nil, policy: self.policy)
  }

  public func handleResponse(data: Data, response: URLResponse) -> Bool {
    PerimeterX.handleResponse(response: response, data: data) { result in
      switch result {
      case .cancelled:
        print("cancelled")
      case .solved:
        print("solved")
      @unknown default:
        fatalError()
      }
    }
  }
}
