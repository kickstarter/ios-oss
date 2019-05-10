import UIKit
import Library
import Prelude

/**
 SheetOverlayContainerViewController intended to be used as a container for another view controller
 that you would like to render as a "sheet" or "card" that partially covers the content beneath it.
 */

final class SheetOverlayContainerViewController: UIViewController {
  private let transitionAnimator = SheetOverlayTransitionAnimator()

  init(childViewController: UIViewController, childViewOffset: CGFloat) {
    super.init(nibName: nil, bundle: nil)

    _ = self
      |> \.modalPresentationStyle .~ .custom
      |> \.transitioningDelegate .~ self

    self.addChild(childViewController)
    self.configureChildView(view: childViewController.view, offset: childViewOffset)

    childViewController.willMove(toParent: self)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureChildView(view: UIView, offset: CGFloat) {
    self.view.addSubview(view)

    let superviewFrame = self.view.frame

    view.frame = CGRect(x: superviewFrame.origin.x,
                        y: offset,
                        width: superviewFrame.width,
                        height: superviewFrame.height - offset)

    if #available(iOS 11.0, *) {
      _ = view.layer
        |> \.masksToBounds .~ true
        |> \.cornerRadius .~ CheckoutStyleConstants.cardStyleRoundedCornerRadius
        |> \.maskedCorners .~ [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
  }
}

extension SheetOverlayContainerViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self.transitionAnimator
  }

  func animationController(forDismissed dismissed: UIViewController) ->
    UIViewControllerAnimatedTransitioning? {
    return self.transitionAnimator
  }
}
