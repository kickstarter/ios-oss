import SafariServices
import UIKit

public extension UIViewController {
  static var supportedURLSchemes = ["http", "https"]

  func goTo(url: URL) {
    if let scheme = url.scheme?.lowercased(), UIViewController.supportedURLSchemes.contains(scheme) {
      let controller = SFSafariViewController(url: url)
      controller.modalPresentationStyle = .overFullScreen
      self.present(controller, animated: true)
    } else if AppEnvironment.current.application.canOpenURL(url) {
      AppEnvironment.current.application.open(url, options: [:], completionHandler: nil)
    }
  }
}
