import Foundation
import PerimeterX

public class PerimeterXClient: NSObject, PerimeterXClientType {
  let dateType: ApiDateProtocol.Type
  let manager: PerimeterXManagerType

  /**
   Custom `HTTPCookie` adding Perimeter X protection to native webviews.
   */
  public lazy var cookie: HTTPCookie? = {
    HTTPCookie(properties: [
      .domain: "www.perimeterx.com", // Change according to the domain the webview will use
      .path: "/",
      .name: "_pxmvid",
      .value: self.manager.getVid() as Any,
      .expires: self.dateType.init(timeIntervalSinceNow: 3_600).date
    ])
  }()

  public init(
    manager: PerimeterXManagerType = PXManager.sharedInstance(),
    dateType: ApiDateProtocol.Type = Date.self
  ) {
    self.manager = manager
    self.dateType = dateType

    super.init()

    /// When this isn't a mock we'll set the delegate and have debug logging in the console.
    (self.manager as? PXManager)?.delegate = self
  }

  public func handleError(response: HTTPURLResponse, and data: Data) -> Bool {
    /// We have a `403` statusCode.
    guard response.statusCode == 403 else { return false }

    guard
      /// We have `JSON`.
      let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
      /// We have a `PXBlockResponse`.
      let response: PerimeterXBlockResponseType = self.manager.checkError(jsonData),
      /// The response's `PXBlockType` is `Block` or `Captcha`.
      [.Block, .Captcha].contains(response.type)
    else { return false }

    DispatchQueue.main.async {
      NotificationCenter.default.post(
        name: Notification.Name.ksr_perimeterXCaptcha,
        object: nil,
        userInfo: ["response": response]
      )
    }

    return true
  }

  public func headers() -> [String: String] {
    return (self.manager.httpHeaders() as? [String: String]) ?? [:]
  }
}

extension PerimeterXClient: PXManagerDelegate {
  public func managerReady(_ httpHeaders: [AnyHashable: Any]!) {
    print("❎ Perimeter X headers ready: \(String(describing: httpHeaders))")
  }

  public func newHeaders(_ httpHeaders: [AnyHashable: Any]!) {
    print("❎ Perimeter X headers were refreshed: \(String(describing: httpHeaders))")
  }
}
