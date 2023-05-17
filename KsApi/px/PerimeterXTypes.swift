import Foundation
import PerimeterX

// MARK: - PerimeterXClientType

public protocol PerimeterXClientType: ErrorHandler {
  /// Returns an optional `HTTPCookie` for use in authenticating web views to Perimeter X.
  var cookie: HTTPCookie? { get }

  /// Returns a dictionary of `[String: String]`, representing httpHeaders from Perimeter X.
  func headers() -> [String: String]

  /// Calls the start method to configure the SDK
  func start()

  /// Handles the captcha message from a `PXBlockResponse`
  func handle(_ blockResponse: PXBlockResponse!, with presentingViewController: UIViewController!,
              captchaSuccess successBlock: PXCompletionBlock!)
}

// MARK: - PerimeterXManagerType

public protocol PerimeterXManagerType {
  func checkError(_ responseJson: [AnyHashable: Any]!) -> PerimeterXBlockResponseType?
  func getVid() -> String!
  func httpHeaders() -> [AnyHashable: Any]!
  func start(_ appId: String!)
  func handle(_ blockResponse: PXBlockResponse!, with presentingViewController: UIViewController!,
              captchaSuccess successBlock: PXCompletionBlock!)
}

extension PXManager: PerimeterXManagerType {
  public func start(_ appId: String!) {
    self.start(with: appId)
  }

  public func checkError(_ responseJson: [AnyHashable: Any]!) -> PerimeterXBlockResponseType? {
    self.checkError(responseJson) as PerimeterXBlockResponseType
  }
}

// MARK: - PerimeterXBlockResponseType

public protocol PerimeterXBlockResponseType {
  var type: PXBlockType { get }

  func displayCaptcha(on client: PerimeterXClientType, vc: UIViewController?)
}

extension PXBlockResponse: PerimeterXBlockResponseType {
  public func displayCaptcha(on client: PerimeterXClientType, vc: UIViewController?) {
    guard let viewController = vc else {
      print("❌ Perimeter X CAPTCHA failed. No view controller.")

      return
    }

    client.handle(self, with: viewController) {
      print("❎ Perimeter X CAPTCHA was successful.")
    }
  }
}
