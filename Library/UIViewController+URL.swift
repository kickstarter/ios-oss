import SafariServices
import UIKit

public extension UIViewController {
  static var supportedURLSchemes = ["http", "https"]

  func goTo(url: URL, application: UIApplicationType = UIApplication.shared) {
    if let scheme = url.scheme?.lowercased(), UIViewController.supportedURLSchemes.contains(scheme) {
      let controller = SFSafariViewController(url: url)
      controller.modalPresentationStyle = .overFullScreen
      self.present(controller, animated: true)
    } else if application.canOpenURL(url) {
      application.open(url, options: [:], completionHandler: nil)
    }
  }
}
