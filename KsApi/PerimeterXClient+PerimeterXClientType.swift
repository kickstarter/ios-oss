import Foundation
import PerimeterX

public class PerimeterXClient: PerimeterXClientType {
  /**
   Custom `HTTPCookie` adding Perimeter X protection to native webviews.
   */
  public static var cookie = HTTPCookie(properties: [
      .domain: "www.perimeterx.com", // Change according to the domain the webview will use
      .path: "/",
      .name: "_pxmvid",
      .value: PXManager.sharedInstance().getVid() as Any,
      .secure: "FALSE",
      .expires: Date(timeIntervalSinceNow: 3_600)
    ])

  public init() {}

  public func handleError(blockResponse: HTTPURLResponse, and data: Data) -> Bool {
    /// We have a `403` statusCode.
    guard blockResponse.statusCode == 403 else { return false }

    guard
      /// We have `JSON`.
      let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
      /// We have a `PXBlockResponse`.
      let response = PXManager.sharedInstance().checkError(jsonData),
      /// The response's `PXBlockType` is `Block` or `Captcha`.
      [.Block, .Captcha].contains(response.type)
    else { return false }

    DispatchQueue.main.async {
      PXManager.sharedInstance().handle(response, with: UIApplication.shared.keyWindow?.rootViewController) {
        print("❎ Perimeter X CAPTCHA was successful.")
      }
    }

    return true
  }

  public func headers() -> [String: String] {
    return (PXManager.sharedInstance().httpHeaders() as? [String: String]) ?? [:]
  }
}
