import UIKit

private let dismissedOverlayColor = UIColor(white: 1, alpha: 0)
private let presentedOverlayColor = UIColor(white: 1, alpha: 1)

internal final class ProjectNavigatorTransitionAnimator: UIPercentDrivenInteractiveTransition,
UIViewControllerAnimatedTransitioning {

  fileprivate let darkOverlayView = UIView()

  /// Determines if the transition animation is currently "in flight", i.e. the user is actively interacting
  /// with the dismissal.
  internal var isInFlight = false

  internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
    -> TimeInterval {

      return transitionContext?.isInteractive == .some(true) ? 0.6 : 0.4
  }

  internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
      let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
      else {
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

  fileprivate func animatePresentation(
    fromViewController fromVC: UIViewController,
    toViewController toVC: UIViewController,
    containerView: UIView,
    transitionContext: UIViewControllerContextTransitioning) {

    containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
    containerView.insertSubview(self.darkOverlayView, belowSubview: toVC.view)

    self.darkOverlayView.frame = containerView.bounds
    self.darkOverlayView.backgroundColor = dismissedOverlayColor

    let bottomLeftCorner = CGPoint(x: 0, y: containerView.bounds.height)
    let finalFrame = CGRect(origin: .zero, size: containerView.bounds.size)

    toVC.view.frame = CGRect(origin: bottomLeftCorner, size: containerView.bounds.size)

    UIView.animate(
      withDuration: self.transitionDuration(using: transitionContext),
      delay: 0,
      options: [.curveEaseOut],
      animations: {
        toVC.view.frame = finalFrame
        self.darkOverlayView.backgroundColor = presentedOverlayColor
      },
      completion: { _ in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      }
    )
  }

  fileprivate func animateDismissal(fromViewController fromVC: UIViewController,
                                    toViewController toVC: UIViewController,
                                    containerView: UIView,
                                    transitionContext: UIViewControllerContextTransitioning) {

    containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
    containerView.insertSubview(self.darkOverlayView, belowSubview: fromVC.view)

    self.darkOverlayView.frame = containerView.bounds
    self.darkOverlayView.backgroundColor = presentedOverlayColor

    let bottomLeftCorner = CGPoint(x: 0, y: containerView.bounds.height)
    let finalFrame = CGRect(origin: bottomLeftCorner, size: containerView.bounds.size)
    toVC.view.frame = containerView.bounds

    let animationCurve: UIViewAnimationOptions = transitionContext.isInteractive == .some(true)
      ? .curveLinear
      : .curveEaseOut

    UIView.animate(
      withDuration: self.transitionDuration(using: transitionContext),
      delay: 0,
      options: [animationCurve],
      animations: {
        fromVC.view.frame = finalFrame
        if transitionContext.isInteractive {
          fromVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        self.darkOverlayView.backgroundColor = dismissedOverlayColor
      },
      completion: { _ in
        self.darkOverlayView.backgroundColor = transitionContext.transitionWasCancelled
          ? .black
          : self.darkOverlayView.backgroundColor
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      }
    )
  }
}
