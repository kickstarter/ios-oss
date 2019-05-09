import UIKit

final class SheetOverlayTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromVC = transitionContext.viewController(forKey: .from),
      let toVC = transitionContext.viewController(forKey: .to) else {
        return
    }

    let containerView = transitionContext.containerView

    if toVC.isBeingPresented {
      self.animatePresentation(fromViewController: fromVC,
                               toViewController: toVC,
                               containerView: containerView,
                               transitionContext: transitionContext)
    } else {
      self.animateDismissal(fromViewController: fromVC,
                            toViewController: toVC,
                            containerView: containerView,
                            transitionContext: transitionContext)
    }
  }

  private func animatePresentation(
    fromViewController fromVC: UIViewController,
    toViewController toVC: UIViewController,
    containerView: UIView,
    transitionContext: UIViewControllerContextTransitioning) {

    let darkOverlay = UIView(frame: fromVC.view.frame)
    darkOverlay.backgroundColor = UIColor.ksr_soft_black.withAlphaComponent(0.8)
    darkOverlay.alpha = 0.0

    toVC.view.backgroundColor = .clear

    toVC.view.frame = fromVC.view.frame.offsetBy(dx: 0, dy: toVC.view.frame.height)

    containerView.addSubview(darkOverlay)
    containerView.addSubview(toVC.view)

    let toFrame = fromVC.view.frame

    UIView.animate(
      withDuration: self.transitionDuration(using: transitionContext),
      delay: 0,
      options: .curveEaseInOut,
      animations: {
        toVC.view.frame = toFrame
        darkOverlay.alpha = 1.0
    }, completion: { _ in
      toVC.view.backgroundColor = darkOverlay.backgroundColor
      darkOverlay.removeFromSuperview()
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })
  }

  private func animateDismissal(fromViewController fromVC: UIViewController,
                                toViewController toVC: UIViewController,
                                containerView: UIView,
                                transitionContext: UIViewControllerContextTransitioning) {
    let darkOverlay = UIView(frame: toVC.view.frame)
    darkOverlay.backgroundColor = UIColor.ksr_soft_black.withAlphaComponent(0.8)
    darkOverlay.alpha = 1.0

    containerView.insertSubview(darkOverlay, belowSubview: fromVC.view)

    fromVC.view.backgroundColor = .clear

    let toFrame = toVC.view.frame.offsetBy(dx: 0, dy: fromVC.view.frame.height)

    UIView.animate(
      withDuration: self.transitionDuration(using: transitionContext),
      delay: 0,
      options: .curveEaseInOut,
      animations: {
        fromVC.view.frame = toFrame
        darkOverlay.alpha = 0.0
    }, completion: { _ in
      darkOverlay.removeFromSuperview()
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })
  }
}
