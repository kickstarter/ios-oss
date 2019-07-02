import UIKit

public class RewardPledgePopTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  public func transitionDuration(
    using _: UIViewControllerContextTransitioning?
  ) -> TimeInterval {
    return 0.3
  }

  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let toView = transitionContext.view(forKey: .to) else { return }

    transitionContext.containerView.addSubview(toView)
    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
  }
}
