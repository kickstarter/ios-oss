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
    static let dampingRatio: CGFloat = 0.836
    static let frequencyResponse: CGFloat = 0.233
    static let shadowOpacity: CGFloat = 0.17
  }
}

public class RewardPledgePushTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  private let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParams())

  public func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
    return self.animator.duration
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

    _ = (toView, containerView)
      |> ksr_addSubviewToParent()
    _ = (fromView, containerView)
      |> ksr_addSubviewToParent()

    containerView.layoutIfNeeded()

    let (snapshotView, snapshotSourceFrame, maskFrame) = snapshotData
    _ = snapshotView
      |> \.frame .~ snapshotSourceFrame

    addMaskToRewardCardContainerView(snapshotView, maskFrame: maskFrame)

    let (snapshotShadowContainerView, expandIconImageView) = shadowContainerViewAndExpandIconImageView(
      with: snapshotData,
      addedToContainerView: containerView,
      operation: operation
    )

    _ = toView
      |> \.alpha .~ 0

    toVC.beginTransition(operation)
    fromDelegate.beginTransition(operation)

    guard let destinationFrameData = toVC.destinationFrameData(withContainerView: containerView) else {
      forceTransition(with: transitionContext, operation: operation)
      return
    }
    let (destinationFrame, destinationMask) = destinationFrameData

    _ = toView
      |> \.frame .~ containerView.bounds.offsetBy(dx: 0, dy: Styles.grid(10))

    let shadowAnimation = newShadowAnimation(for: operation)

    self.animator.addAnimations {
      snapshotShadowContainerView.layer.add(shadowAnimation, forKey: shadowAnimation.keyPath.coalesceWith(""))

      _ = snapshotShadowContainerView
        |> \.frame .~ destinationFrame
      _ = snapshotView
        |> \.frame .~ snapshotShadowContainerView.bounds

      snapshotView.mask?.frame = destinationMask

      _ = expandIconImageView
        |> \.alpha .~ 1

      updateExpandIconImageViewFrame(
        expandIconImageView,
        inSnapshotShadowContainerView: snapshotShadowContainerView
      )

      _ = fromView
        |> \.alpha .~ 0

      _ = toView
        |> \.frame .~ containerView.bounds
      _ = toView
        |> \.alpha .~ 1
    }

    self.animator.addCompletion { _ in
      snapshotShadowContainerView.removeFromSuperview()

      toVC.endTransition(operation)
      fromDelegate.endTransition(operation)
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

    self.animator.startAnimation()
  }
}

public class RewardPledgePopTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  private let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParams())

  public func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
    return self.animator.duration
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
    _ = snapshotView
      |> \.frame .~ snapshotSourceFrame
    addMaskToRewardCardContainerView(snapshotView, maskFrame: maskFrame)

    _ = (toView, containerView)
      |> ksr_addSubviewToParent()
    _ = (fromView, containerView)
      |> ksr_addSubviewToParent()

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

    let shadowAnimation = newShadowAnimation(for: operation)

    self.animator.addAnimations {
      snapshotShadowContainerView.layer.add(shadowAnimation, forKey: shadowAnimation.keyPath.coalesceWith(""))

      _ = snapshotShadowContainerView
        |> \.frame .~ destinationFrame
      _ = snapshotView
        |> \.frame .~ snapshotShadowContainerView.bounds

      snapshotView.mask?.frame = destinationMask

      _ = expandIconImageView
        |> \.alpha .~ 0

      updateExpandIconImageViewFrame(
        expandIconImageView,
        inSnapshotShadowContainerView: snapshotShadowContainerView
      )

      _ = fromView
        |> \.alpha .~ 0
      _ = fromView
        |> \.frame .~ containerView.bounds.offsetBy(dx: 0, dy: Styles.grid(10))

      _ = toView
        |> \.alpha .~ 1
    }

    self.animator.addCompletion { _ in
      snapshotShadowContainerView.removeFromSuperview()

      fromVC.endTransition(operation)
      toDelegate.endTransition(operation)
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

    self.animator.startAnimation()
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

  _ = (snapshotShadowContainerView, containerView)
    |> ksr_addSubviewToParent()
  _ = (snapshotView, snapshotShadowContainerView)
    |> ksr_addSubviewToParent()

  _ = snapshotView
    |> \.frame .~ snapshotShadowContainerView.bounds

  let expandIconImageView = UIImageView(image: image(named: "icon-expansion"))
    |> \.alpha .~ (operation == .push ? 0 : 1)

  _ = (expandIconImageView, snapshotShadowContainerView)
    |> ksr_addSubviewToParent()

  updateExpandIconImageViewFrame(
    expandIconImageView,
    inSnapshotShadowContainerView: snapshotShadowContainerView
  )

  return (snapshotShadowContainerView, expandIconImageView)
}

private func newShadowAnimation(for operation: UINavigationController.Operation) -> CABasicAnimation {
  return CABasicAnimation(keyPath: "shadowOpacity")
    |> \.fillMode .~ .forwards
    |> \.isRemovedOnCompletion .~ false
    |> \.fromValue .~ (operation == .push ? 0 : Constant.Animation.shadowOpacity)
    |> \.toValue .~ (operation == .push ? Constant.Animation.shadowOpacity : 0)
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

  _ = (toView, containerView)
    |> ksr_addSubviewToParent()
  _ = (fromView, containerView)
    |> ksr_addSubviewToParent()

  _ = fromView
    |> \.alpha .~ 0
  _ = toView
    |> \.alpha .~ 1

  toDelegate.endTransition(operation)
  fromDelegate.endTransition(operation)

  transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
}

private func addMaskToRewardCardContainerView(_ view: UIView, maskFrame: CGRect) {
  let mask = UIView(frame: maskFrame)
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.backgroundColor .~ .black

  _ = view
    |> \.mask .~ mask
}

private func springTimingParams() -> UISpringTimingParameters {
  return UISpringTimingParameters(
    dampingRatio: Constant.Animation.dampingRatio,
    frequencyResponse: Constant.Animation.frequencyResponse
  )
}
