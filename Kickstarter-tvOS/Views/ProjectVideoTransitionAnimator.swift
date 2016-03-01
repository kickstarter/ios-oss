import UIKit
import AVFoundation

class ProjectVideoTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  let player: AVPlayer
  let playerLayer: AVPlayerLayer
  var isPresenting: Bool = false

  init(player: AVPlayer, playerLayer: AVPlayerLayer) {
    self.player = player
    self.playerLayer = playerLayer
  }

  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 1.0
  }

  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    guard let
      from = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
      to = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
      fromView = from.view,
      toView = to.view else { return }

    fromView.alpha = 1.0
    fromView.transform = CGAffineTransformIdentity
    toView.alpha = 0.0
    toView.transform = CGAffineTransformMakeScale(0.9, 0.9)

    if isPresenting {
      transitionContext.containerView()?.addSubview(toView)
    }

    UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
      fromView.alpha = 0.0
      fromView.transform = CGAffineTransformMakeScale(0.9, 0.9)
      toView.alpha = 1.0
      toView.transform = CGAffineTransformIdentity
      }, completion: { _ in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
    })
  }
}
