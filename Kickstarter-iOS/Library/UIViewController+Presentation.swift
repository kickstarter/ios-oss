import Foundation
import Library
import UIKit

extension UIViewController {
  internal func presentHelpWebViewController(with helpType: HelpType,
                                             presentationStyle: UIModalPresentationStyle = .fullScreen) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    let nc = UINavigationController(rootViewController: vc)
    nc.modalPresentationStyle = presentationStyle

    self.present(nc, animated: true)
  }
}
