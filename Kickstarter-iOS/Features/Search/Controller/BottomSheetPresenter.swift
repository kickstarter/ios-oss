import Library
import SwiftUI
import UIKit

final class BottomSheetPresenter {
  private let transitioningDelegate = BottomSheetTransitioningDelegate()

  func present(viewController: UIViewController, from parentViewController: UIViewController) {
    viewController.modalPresentationStyle = .custom
    viewController.transitioningDelegate = self.transitioningDelegate
    parentViewController.present(viewController, animated: true)
  }
}

final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  func presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source _: UIViewController
  ) -> UIPresentationController? {
    return BottomSheetPresentationController(
      presentedViewController: presented,
      presenting: presenting
    )
  }
}

final class BottomSheetPresentationController: UIPresentationController {
  private let maxHeightRatio: CGFloat = 0.8
  private let cornerRadius: CGFloat = Styles.grid(2)
  private let dimmingView = UIView()

  override var frameOfPresentedViewInContainerView: CGRect {
    guard let containerView = containerView else { return .zero }

    let targetHeight = presentedView?.systemLayoutSizeFitting(
      CGSize(width: containerView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
    ).height ?? 0

    let height = min(targetHeight, containerView.bounds.height * self.maxHeightRatio)

    return CGRect(
      x: 0,
      y: containerView.bounds.height - height,
      width: containerView.bounds.width,
      height: height
    )
  }

  override func presentationTransitionWillBegin() {
    guard let containerView = containerView else { return }

    self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    self.dimmingView.frame = containerView.bounds
    self.dimmingView.alpha = 0

    containerView.insertSubview(self.dimmingView, at: 0)

    presentedView?.layer.cornerRadius = self.cornerRadius
    presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    presentedView?.layer.masksToBounds = true

    if let transitionCoordinator = presentingViewController.transitionCoordinator {
      transitionCoordinator.animate(alongsideTransition: { _ in
        self.dimmingView.alpha = 1
      })
    } else {
      self.dimmingView.alpha = 1
    }
  }

  override func dismissalTransitionWillBegin() {
    if let transitionCoordinator = presentingViewController.transitionCoordinator {
      transitionCoordinator.animate(alongsideTransition: { _ in
        self.dimmingView.alpha = 0
      })
    } else {
      self.dimmingView.alpha = 0
    }
  }

  override func containerViewDidLayoutSubviews() {
    super.containerViewDidLayoutSubviews()
    self.dimmingView.frame = containerView?.bounds ?? .zero
  }
}
