import UIKit

final class ProjectTrayTransitionAnimator : NSObject, UIViewControllerAnimatedTransitioning {
  var isPresenting: Bool = false
  lazy var darkenOverlay: UIView = {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 1920, height: 1080))
    view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
    view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    return view
  }()

  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.5
  }

  func animateTransition(context: UIViewControllerContextTransitioning) {

    guard let
      from = context.viewControllerForKey(UITransitionContextFromViewControllerKey),
      to = context.viewControllerForKey(UITransitionContextToViewControllerKey),
      trayController = (from as? PlaylistTrayViewController) ?? (to as? PlaylistTrayViewController),
      trayView = trayController.view,
      containerView = context.containerView()
    else { return }

    let offset = CGAffineTransformMakeTranslation(0.0, -trayView.frame.height)
    let offsetInv = CGAffineTransformMakeTranslation(0.0, trayView.frame.height)

    if isPresenting {
      containerView.addSubview(darkenOverlay)
      containerView.addSubview(trayView)

      darkenOverlay.alpha = 0.0
      trayView.transform = offset
    }

    UIView.animateWithDuration(transitionDuration(context), animations: {

      if self.isPresenting {
        self.darkenOverlay.alpha = 1.0
        self.darkenOverlay.transform = offsetInv
        trayView.transform = CGAffineTransformIdentity
      } else {
        self.darkenOverlay.alpha = 0.0
        self.darkenOverlay.transform = CGAffineTransformIdentity
        trayView.transform = offset
      }
    }, completion: { _ in
      context.completeTransition(!context.transitionWasCancelled())
    })
  }
}
