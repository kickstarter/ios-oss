import UIKit

// A view controller intended to be used as a container for another view controller
// CardContainerViewController masks the contained VC in a "card-like" way

final class CardContainerViewController: UIViewController {
  private let transitionAnimator = SheetOverlayTransitionAnimator()

  init(childViewController: UIViewController, childViewOffset: CGFloat) {
    super.init(nibName: nil, bundle: nil)

    self.modalPresentationStyle = .pageSheet

    self.addChild(childViewController)
    self.configureChildView(view: childViewController.view, offset: childViewOffset)

    childViewController.willMove(toParent: self)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureChildView(view: UIView, offset: CGFloat) {
    self.view.addSubview(view)

    view.frame = self.view.frame.offsetBy(dx: 0, dy: offset)
    view.layer.cornerRadius = 12
    view.layer.masksToBounds = true
  }
}

extension CardContainerViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self.transitionAnimator
  }

  func animationController(forDismissed dismissed: UIViewController) ->
    UIViewControllerAnimatedTransitioning? {
    return self.transitionAnimator
  }
}
