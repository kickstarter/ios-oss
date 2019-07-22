import Library
import Prelude
import UIKit

public typealias RewardPledgeTransitionSnapshotData = (
  snapshotView: UIView,
  sourceFrame: CGRect,
  maskFrame: CGRect
)

public typealias RewardPledgeTransitionDestinationFrameData = (
  destination: CGRect,
  mask: CGRect
)

public protocol RewardPledgeTransitionAnimatorDelegate: AnyObject {
  func beginTransition(_ operation: UINavigationController.Operation)
  func snapshotData(withContainerView view: UIView) -> RewardPledgeTransitionSnapshotData?
  func destinationFrameData(withContainerView view: UIView) -> RewardPledgeTransitionDestinationFrameData?
  func endTransition(_ operation: UINavigationController.Operation)
}

private enum Constant {
  enum Animation {
    static let timeInterval: TimeInterval = 0.38
    static let damping: CGFloat = 0.8
    static let shadowOpacity: CGFloat = 0.17
  }
}

public class RewardPledgePushTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  public func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
    return Constant.Animation.timeInterval
  }

  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let operation: UINavigationController.Operation = .push

    let containerView = transitionContext.containerView

    guard
      let toVC = transitionContext.viewController(forKey: .to) as? PledgeViewController,
      let toView = transitionContext.view(forKey: .to),
      let fromDelegate = transitionContext.viewController(forKey: .from)
      as? RewardPledgeTransitionAnimatorDelegate,
      let fromView = transitionContext.view(forKey: .from),
      let snapshotData = fromDelegate.snapshotData(withContainerView: containerView)
    else {
      // something went wrong, fall back to no transition
      forceTransition(with: transitionContext, operation: operation)
      return
    }

    _ = containerView
      |> \.backgroundColor .~ fromView.backgroundColor

    containerView.addSubview(toView)
    containerView.addSubview(fromView)
    containerView.layoutIfNeeded()

    let (snapshotView, snapshotSourceFrame, maskFrame) = snapshotData
    snapshotView.frame = snapshotSourceFrame

    addMaskToRewardCardContainerView(snapshotView, maskFrame: maskFrame)

    let (snapshotShadowContainerView, expandIconImageView) = shadowContainerViewAndExpandIconImageView(
      with: snapshotData,
      addedToContainerView: containerView,
      operation: operation
    )

    toView.alpha = 0

    toVC.beginTransition(operation)
    fromDelegate.beginTransition(operation)

    guard let destinationFrameData = toVC.destinationFrameData(withContainerView: containerView) else {
      forceTransition(with: transitionContext, operation: operation)
      return
    }
    let (destinationFrame, destinationMask) = destinationFrameData

    toView.frame = containerView.bounds
      .offsetBy(dx: 0, dy: Styles.grid(10))

    let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParams())

    let shadowAnimation = newShadowAnimation(for: operation)

    animator.addAnimations {
      snapshotShadowContainerView.layer.add(shadowAnimation, forKey: shadowAnimation.keyPath.coalesceWith(""))
      snapshotShadowContainerView.frame = destinationFrame
      snapshotView.frame = snapshotShadowContainerView.bounds
      snapshotView.mask?.frame = destinationMask

      expandIconImageView.alpha = 1
      updateExpandIconImageViewFrame(
        expandIconImageView,
        inSnapshotShadowContainerView: snapshotShadowContainerView
      )

      fromView.alpha = 0

      toView.frame = containerView.bounds
      toView.alpha = 1
    }

    animator.addCompletion { _ in
      snapshotShadowContainerView.removeFromSuperview()

      toVC.endTransition(operation)
      fromDelegate.endTransition(operation)
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

    animator.startAnimation()
  }
}

public class RewardPledgePopTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  public func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
    return Constant.Animation.timeInterval
  }

  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let operation: UINavigationController.Operation = .pop

    let containerView = transitionContext.containerView

    guard
      let fromVC = transitionContext.viewController(forKey: .from) as? PledgeViewController,
      let toView = transitionContext.view(forKey: .to),
      let toDelegate = transitionContext.viewController(forKey: .to)
      as? RewardPledgeTransitionAnimatorDelegate,
      let fromView = transitionContext.view(forKey: .from),
      let snapshotData = fromVC.snapshotData(withContainerView: containerView)
    else {
      // something went wrong, fall back to no transition
      forceTransition(with: transitionContext, operation: operation)
      return
    }

    _ = containerView
      |> \.backgroundColor .~ toView.backgroundColor

    let (snapshotView, snapshotSourceFrame, maskFrame) = snapshotData
    snapshotView.frame = snapshotSourceFrame
    addMaskToRewardCardContainerView(snapshotView, maskFrame: maskFrame)

    containerView.addSubview(toView)
    containerView.addSubview(fromView)

    let (snapshotShadowContainerView, expandIconImageView) = shadowContainerViewAndExpandIconImageView(
      with: snapshotData,
      addedToContainerView: containerView,
      operation: operation
    )

    fromVC.beginTransition(operation)
    toDelegate.beginTransition(operation)

    guard let destinationFrameData = toDelegate.destinationFrameData(withContainerView: containerView) else {
      forceTransition(with: transitionContext, operation: operation)
      return
    }

    let (destinationFrame, destinationMask) = destinationFrameData

    let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParams())

    let shadowAnimation = newShadowAnimation(for: operation)

    animator.addAnimations {
      snapshotShadowContainerView.layer.add(shadowAnimation, forKey: shadowAnimation.keyPath.coalesceWith(""))
      snapshotShadowContainerView.frame = destinationFrame
      snapshotView.frame = snapshotShadowContainerView.bounds
      snapshotView.mask?.frame = destinationMask

      expandIconImageView.alpha = 0
      updateExpandIconImageViewFrame(
        expandIconImageView,
        inSnapshotShadowContainerView: snapshotShadowContainerView
      )

      fromView.alpha = 0
      fromView.frame = containerView.bounds
        .offsetBy(dx: 0, dy: Styles.grid(10))

      toView.alpha = 1
    }

    animator.addCompletion { _ in
      snapshotShadowContainerView.removeFromSuperview()

      fromVC.endTransition(operation)
      toDelegate.endTransition(operation)
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

    animator.startAnimation()
  }
}

// MARK: - Shared

private func shadowContainerViewAndExpandIconImageView(
  with snapshotData: RewardPledgeTransitionSnapshotData,
  addedToContainerView containerView: UIView,
  operation: UINavigationController.Operation
) -> (UIView, UIView) {
  let (snapshotView, snapshotSourceFrame, _) = snapshotData

  let snapshotShadowContainerView = UIView(frame: snapshotSourceFrame)
    |> rewardCardShadowStyle
    |> \.layer.shadowOpacity .~ Float(operation == .push ? 0 : Constant.Animation.shadowOpacity)

  containerView.addSubview(snapshotShadowContainerView)
  snapshotShadowContainerView.addSubview(snapshotView)
  snapshotView.frame = snapshotShadowContainerView.bounds

  let expandIconImageView = UIImageView(image: image(named: "icon-expansion"))
  expandIconImageView.alpha = operation == .push ? 0 : 1
  snapshotShadowContainerView.addSubview(expandIconImageView)

  updateExpandIconImageViewFrame(
    expandIconImageView,
    inSnapshotShadowContainerView: snapshotShadowContainerView
  )

  return (snapshotShadowContainerView, expandIconImageView)
}

private func newShadowAnimation(for operation: UINavigationController.Operation) -> CABasicAnimation {
  let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
  shadowAnimation.fillMode = .forwards
  shadowAnimation.isRemovedOnCompletion = false
  shadowAnimation.fromValue = operation == .push ? 0 : Constant.Animation.shadowOpacity
  shadowAnimation.toValue = operation == .push ? Constant.Animation.shadowOpacity : 0

  return shadowAnimation
}

private func updateExpandIconImageViewFrame(
  _ expandIconImageView: UIView,
  inSnapshotShadowContainerView snapshotShadowContainerView: UIView
) {
  expandIconImageView.frame = CGRect(
    origin: CGPoint(
      x: (snapshotShadowContainerView.bounds.maxX - expandIconImageView.bounds.size.width) + Styles.grid(1),
      y: snapshotShadowContainerView.bounds.minY - Styles.grid(1)
    ), size: expandIconImageView.bounds.size
  )
}

private func forceTransition(
  with transitionContext: UIViewControllerContextTransitioning,
  operation: UINavigationController.Operation
) {
  guard
    let toView = transitionContext.view(forKey: .to),
    let fromView = transitionContext.view(forKey: .from),
    let toDelegate = transitionContext.viewController(forKey: .to)
    as? RewardPledgeTransitionAnimatorDelegate,
    let fromDelegate = transitionContext.viewController(forKey: .from)
    as? RewardPledgeTransitionAnimatorDelegate
  else {
    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    return
  }

  let containerView = transitionContext.containerView

  containerView.addSubview(fromView)
  containerView.addSubview(toView)

  fromView.alpha = 0
  toView.alpha = 1

  toDelegate.endTransition(operation)
  fromDelegate.endTransition(operation)

  transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
}

private func addMaskToRewardCardContainerView(_ view: UIView, maskFrame: CGRect) {
  let mask = UIView(frame: maskFrame)
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.backgroundColor .~ .black

  view.mask = mask
}

private func springTimingParams() -> UISpringTimingParameters {
  return UISpringTimingParameters(dampingRatio: 0.836, frequencyResponse: 0.233)
}
