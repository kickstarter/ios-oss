import Foundation
import PerimeterX

public extension PXManager {
  /**
   Returns a `PXManager` instance, for PerimeterX.
   */
  static func configuredClient() -> PXManager {
    if let pxManager = PXManager.sharedInstance() {
      return pxManager
    }
    return PXManager.init()
  }
}

public protocol PerimeterXClientType: AnyObject {
  func handlePX(blockResponse: HTTPURLResponse, and data: Data)
  func headers() -> [String: String]
}

extension PXManager: PerimeterXClientType {
  public func handlePX(blockResponse: HTTPURLResponse, and data: Data) {
    if blockResponse.statusCode == 403 {
      let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      let blockResponse = PXManager.configuredClient().checkError(jsonData)

      if blockResponse?.type == PXBlockType.Block || blockResponse?.type == PXBlockType.Captcha {
        DispatchQueue.main.async {
          guard let window = UIApplication.shared.keyWindow else {
            return
          }

          PXManager.configuredClient().handle(blockResponse, with: window.rootViewController) {
            print("*** success!")
          }
        }
      }
    }
  }

  public func headers() -> [String: String] {
    return (PXManager.configuredClient().httpHeaders() as! [String: String])
  }
}
