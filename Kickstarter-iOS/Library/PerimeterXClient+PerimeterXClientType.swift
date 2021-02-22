import KsApi
import PerimeterX

public class PerimeterXClient: PerimeterXClientType {
  /**
   Custom `HTTPCookie` adding Perimeter X protection to native webviews.
   */
  public static var cookie = HTTPCookie(properties: [
    .domain: "www.perimeterx.com", // Change according to the domain the webview will use
    .path: "/",
    .name: "_pxmvid",
    .value: PXManager.sharedInstance()?.getVid() ?? "",
    .secure: "FALSE",
    .expires: NSDate(timeIntervalSinceNow: 3_600)
  ])

  /**
   Sets the delegate for the sharedInstance of the `PXManager` and starts it with the obfuscated Perimeter X App ID.

   - parameter pxManagerDelegate: An object conforming to the `PXManagerDelegate` class.
   */
  public static func startPerimeterX(with pxManagerDelegate: PXManagerDelegate) {
    PXManager.sharedInstance().delegate = pxManagerDelegate
    PXManager.sharedInstance()?.start(with: Secrets.perimeterxAppId)
  }

  public init() {}

  public func handleError(blockResponse: HTTPURLResponse, and data: Data) {
    if blockResponse.statusCode == 403 {
      let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      let blockResponse = PXManager.sharedInstance().checkError(jsonData)

      if blockResponse?.type == PXBlockType.Block || blockResponse?.type == PXBlockType.Captcha {
        DispatchQueue.main.async {
          guard let window = UIApplication.shared.keyWindow else {
            return
          }

          PXManager.sharedInstance().handle(blockResponse, with: window.rootViewController) {
            print("❌ Perimeter X CAPTCHA was successful.")
          }
        }
      }
    }
  }

  public func headers() -> [String: String] {
    return (PXManager.sharedInstance().httpHeaders() as? [String: String]) ?? [:]
  }
}
