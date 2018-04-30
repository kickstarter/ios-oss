import UIKit

internal final class ScrollingTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  weak var transitionContext: UIViewControllerContextTransitioning?
  var tabBarController: UITabBarController!
  var lastIndex = 0

  public init(tabBarController: UITabBarController, lastIndex: Int) {
    self.tabBarController = tabBarController
    self.lastIndex = lastIndex
  }

  internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
    -> TimeInterval {
    return 0.25
  }

  internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
      let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
    else {
      return
    }

    toVC.view.alpha = 0.0
    transitionContext.containerView.addSubview(fromVC.view)
    transitionContext.containerView.addSubview(toVC.view)

    UIView.animate(withDuration: self.transitionDuration(using: (self.transitionContext)), animations: {
      toVC.view.alpha = 1.0
    }) { _ in
      fromVC.view.removeFromSuperview()
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
  }
}
