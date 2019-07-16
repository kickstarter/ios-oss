import Foundation
import UIKit
import Library

extension UIViewController {
  internal func presentHelpWebViewController(with helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    let nc = UINavigationController(rootViewController: vc)
    self.present(nc, animated: true)
  }
}
