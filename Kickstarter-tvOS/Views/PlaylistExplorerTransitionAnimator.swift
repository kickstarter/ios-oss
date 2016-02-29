import UIKit

class PlaylistExplorerTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  var isPresenting: Bool = false
  let blurOverlay = UIVisualEffectView()

  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.5
  }

  func animateTransition(context: UIViewControllerContextTransitioning) {
    guard let
      from = context.viewControllerForKey(UITransitionContextFromViewControllerKey),
      to = context.viewControllerForKey(UITransitionContextToViewControllerKey),
      fromView = from.view,
      toView = to.view,
      containerView = context.containerView() else { return }

    let modalView = self.isPresenting ? toView : fromView

    if isPresenting {
      self.blurOverlay.frame = containerView.bounds
      containerView.addSubview(self.blurOverlay)
      containerView.addSubview(toView)
      modalView.alpha = 0.0

      UIView.animateKeyframesWithDuration(1.0, delay: 0.0, options: [], animations: {
        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.7) {
          self.blurOverlay.effect = UIBlurEffect(style: .Dark)
        }
        UIView.addKeyframeWithRelativeStartTime(0.7, relativeDuration: 0.3) {
          modalView.alpha = 1.0
        }
      }, completion: { _ in
          context.completeTransition(!context.transitionWasCancelled())
      })
    } else {
      UIView.animateWithDuration(0.6, animations: {
        self.blurOverlay.effect = nil
        modalView.alpha = 0.0
      }, completion: { _ in
        context.completeTransition(!context.transitionWasCancelled())
      })
    }
  }
}
