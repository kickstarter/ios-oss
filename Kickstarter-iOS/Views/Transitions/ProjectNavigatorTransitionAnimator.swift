import UIKit

private let dismissedOverlayColor = UIColor(white: 0, alpha: 0)
private let presentedOverlayColor = UIColor(white: 0, alpha: 0.7)

internal final class ProjectNavigatorTransitionAnimator: UIPercentDrivenInteractiveTransition,
UIViewControllerAnimatedTransitioning {

  private let darkOverlayView = UIView()

  /// Determines if the transition animation is currently "in flight", i.e. the user is actively interacting
  /// with the dismissal.
  internal var isInFlight = false

  internal func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)
    -> NSTimeInterval {

      return transitionContext?.isInteractive() == .Some(true) ? 0.6 : 0.4
  }

  internal func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    guard
      let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
      let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
      let containerView = transitionContext.containerView()
      else {
        return
    }

    if toVC.isBeingPresented() {
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

    containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
    containerView.insertSubview(self.darkOverlayView, belowSubview: toVC.view)

    self.darkOverlayView.frame = containerView.bounds
    self.darkOverlayView.backgroundColor = dismissedOverlayColor

    let bottomLeftCorner = CGPoint(x: 0, y: containerView.bounds.height)
    let finalFrame = CGRect(origin: .zero, size: containerView.bounds.size)

    toVC.view.frame = CGRect(origin: bottomLeftCorner, size: containerView.bounds.size)

    UIView.animateWithDuration(
      self.transitionDuration(transitionContext),
      delay: 0,
      options: [.CurveEaseOut],
      animations: {
        toVC.view.frame = finalFrame
        self.darkOverlayView.backgroundColor = presentedOverlayColor
      },
      completion: { _ in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
      }
    )
  }

  private func animateDismissal(fromViewController fromVC: UIViewController,
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

    let animationCurve: UIViewAnimationOptions = transitionContext.isInteractive() == .Some(true)
      ? .CurveLinear
      : .CurveEaseOut

    UIView.animateWithDuration(
      self.transitionDuration(transitionContext),
      delay: 0,
      options: [animationCurve],
      animations: {
        fromVC.view.frame = finalFrame
        if transitionContext.isInteractive() {
          fromVC.view.transform = CGAffineTransformMakeScale(0.8, 0.8)
        }
        self.darkOverlayView.backgroundColor = dismissedOverlayColor
      },
      completion: { _ in
        self.darkOverlayView.backgroundColor = transitionContext.transitionWasCancelled()
          ? .blackColor()
          : self.darkOverlayView.backgroundColor
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
      }
    )
  }
}
