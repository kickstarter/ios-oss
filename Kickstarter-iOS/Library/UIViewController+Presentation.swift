import Foundation
import Library
import Prelude
import UIKit

extension UIViewController {
  internal func presentHelpWebViewController(with helpType: HelpType,
                                             presentationStyle: UIModalPresentationStyle = .fullScreen) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    let nc = UINavigationController(rootViewController: vc)
    nc.modalPresentationStyle = presentationStyle

    self.present(nc, animated: true)
  }

  /* A helper for presenting a view controller using the sheet overlay,
    while also handling iPad behavior
  */
  internal func presentViewControllerWithSheetOverlay(_ viewController: UIViewController,
                                                      offset: CGFloat) {
    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      _ = viewController
        |> \.modalPresentationStyle .~ .formSheet
        |> \.modalTransitionStyle .~ .crossDissolve

      self.present(viewController, animated: true)
    } else {
      let sheetOverlayViewController = SheetOverlayViewController(
        child: viewController,
        offset: offset
      )

      self.present(sheetOverlayViewController, animated: true)
    }
  }
}
