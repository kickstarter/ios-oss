import Library
import Prelude
import UIKit

final class SheetOverlayTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  private let darkOverlayView: UIView = {
    UIView(frame: .zero)
      |> \.backgroundColor .~ UIColor.ksr_support_700.withAlphaComponent(0.8)
  }()

  func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let fromVC = transitionContext.viewController(forKey: .from),
      let toVC = transitionContext.viewController(forKey: .to) else { return }

    let containerView = transitionContext.containerView

    if toVC.isBeingPresented {
      self.animatePresentation(
        fromViewController: fromVC,
        toViewController: toVC,
        containerView: containerView,
        transitionContext: transitionContext
      )
    } else {
      self.animateDismissal(
        fromViewController: fromVC,
        toViewController: toVC,
        containerView: containerView,
        transitionContext: transitionContext
      )
    }
  }

  // MARK: - Presentation

  private func animatePresentation(
    fromViewController fromVC: UIViewController,
    toViewController toVC: UIViewController,
    containerView: UIView,
    transitionContext: UIViewControllerContextTransitioning
  ) {
    _ = self.darkOverlayView
      |> \.alpha .~ 0.0
      |> \.frame .~ containerView.frame

    _ = toVC.view
      |> \.backgroundColor .~ .clear
      |> \.frame .~ fromVC.view.frame.offsetBy(dx: 0, dy: toVC.view.frame.height)

    _ = (self.darkOverlayView, containerView)
      |> ksr_addSubviewToParent()

    _ = (toVC.view, containerView)
      |> ksr_addSubviewToParent()

    let toFrame = containerView.frame

    UIView.animate(
      withDuration: self.transitionDuration(using: transitionContext),
      delay: 0,
      options: .curveEaseInOut,
      animations: { [weak self] in
        toVC.view.frame = toFrame
        self?.darkOverlayView.alpha = 1.0
      }, completion: { [weak self] _ in
        toVC.view.backgroundColor = self?.darkOverlayView.backgroundColor
        self?.darkOverlayView.removeFromSuperview()

        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      }
    )
  }

  // MARK: - Dismissal

  private func animateDismissal(
    fromViewController fromVC: UIViewController,
    toViewController _: UIViewController,
    containerView: UIView,
    transitionContext: UIViewControllerContextTransitioning
  ) {
    _ = self.darkOverlayView
      |> \.frame .~ containerView.frame
      |> \.alpha .~ 1.0

    _ = fromVC.view
      |> \.backgroundColor .~ .clear
      |> \.frame .~ containerView.frame

    _ = containerView
      |> ksr_insertSubview(self.darkOverlayView, belowSubview: fromVC.view)

    let toFrame = containerView.frame.offsetBy(dx: 0, dy: fromVC.view.frame.height)

    UIView.animate(
      withDuration: self.transitionDuration(using: transitionContext),
      delay: 0,
      options: .curveEaseInOut,
      animations: { [weak self] in
        fromVC.view.frame = toFrame
        self?.darkOverlayView.alpha = 0.0
      }, completion: { [weak self] _ in
        self?.darkOverlayView.removeFromSuperview()

        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      }
    )
  }
}
