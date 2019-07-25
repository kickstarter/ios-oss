import Foundation
import Library
import Prelude
import UIKit

extension UIViewController {
  internal func presentHelpWebViewController(
    with helpType: HelpType,
    presentationStyle: UIModalPresentationStyle = .fullScreen
  ) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    let nc = UINavigationController(rootViewController: vc)
    nc.modalPresentationStyle = presentationStyle

    self.present(nc, animated: true)
  }

  /* A helper for presenting a view controller using the sheet overlay,
   while also handling iPad behavior
   */
  internal func presentViewControllerWithSheetOverlay(
    _ viewController: UIViewController,
    offset: CGFloat
  ) {
    let vc: UIViewController

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      vc = viewController
        |> \.modalPresentationStyle .~ .formSheet
        |> \.modalTransitionStyle .~ .crossDissolve

    } else {
      vc = SheetOverlayViewController(
        child: viewController,
        offset: offset
      )
    }

    self.present(vc, animated: true)
  }
}
