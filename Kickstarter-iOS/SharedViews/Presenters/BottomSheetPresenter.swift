import Library
import SwiftUI
import UIKit

/// A presenter that allows displaying any SwiftUI or UIKit view as a bottom sheet with dynamic height adjustment.
///
/// This presenter handles:
/// - Dynamic height adjustment using `systemLayoutSizeFitting`
/// - Corner radius for a modern appearance
/// - Background dimming to highlight the presented content
/// - Uses `UISheetPresentationController` for iOS 16+
///
/// ## Usage:
/// ```swift
/// let view = SortView(viewModel: viewModel)
/// let hostingController = UIHostingController(rootView: view)
/// let presenter = BottomSheetPresenter()
/// presenter.present(viewController: hostingController, from: self)
/// ```
final class BottomSheetPresenter {
  private let transitioningDelegate = BottomSheetTransitioningDelegate()

  /// Presents a view controller as a bottom sheet from a parent view controller.
  ///
  /// - For iOS 16+, it uses `UISheetPresentationController` to support dynamic height detents.
  /// - For earlier versions, it falls back to a custom `UIPresentationController`.
  ///
  /// - Parameters:
  ///   - viewController: The view controller to present.
  ///   - parentViewController: The view controller that presents the bottom sheet.
  func present(viewController: UIViewController, from parentViewController: UIViewController) {
    // If running on iOS 16+, use UISheetPresentationController for a modern sheet presentation.
    if #available(iOS 16.0, *), viewController.sheetPresentationController != nil {
      self.sheetPrensent(viewController: viewController, from: parentViewController)
      return
    }

    // Fallback for iOS 15 and earlier using a custom presenter.
    viewController.modalPresentationStyle = .custom
    viewController.transitioningDelegate = self.transitioningDelegate
    parentViewController.present(viewController, animated: true)
  }

  @available(iOS 16.0, *)
  private func sheetPrensent(viewController: UIViewController, from parentViewController: UIViewController) {
    guard let sheet = viewController.sheetPresentationController else { return }

    let dynamicHeightDentId = UISheetPresentationController.Detent.Identifier("dynamicHeightDent")
    let dynamicHeightDent = UISheetPresentationController.Detent
      .custom(identifier: dynamicHeightDentId) { _ in
        calculateFittingHeight(of: viewController.view, targetView: parentViewController.view)
      }

    sheet.detents = [dynamicHeightDent]
    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
    sheet.prefersEdgeAttachedInCompactHeight = true
    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true

    parentViewController.present(viewController, animated: true, completion: nil)
  }
}

/// Handles the custom transition for presenting the bottom sheet.
final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  /// Creates a presentation controller to manage the bottom sheet transition.
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

/// Custom presentation controller that handles the layout and appearance of the bottom sheet.
final class BottomSheetPresentationController: UIPresentationController {
  private let cornerRadius: CGFloat = Styles.grid(2)
  private let dimmingView = UIView()

  // Defines the frame for the presented view, adjusting height dynamically.
  override var frameOfPresentedViewInContainerView: CGRect {
    guard let containerView = self.containerView, let presentedView = self.presentedView else { return .zero }

    let height = calculateFittingHeight(of: presentedView, targetView: containerView)

    return CGRect(
      x: 0,
      y: containerView.bounds.height - height,
      width: containerView.bounds.width,
      height: height
    )
  }

  // Sets up the dimming view and rounded corners when the presentation begins.
  override func presentationTransitionWillBegin() {
    guard let containerView = containerView else { return }

    self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    self.dimmingView.frame = containerView.bounds
    self.dimmingView.alpha = 0

    containerView.insertSubview(self.dimmingView, at: 0)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapOutside))
    self.dimmingView.addGestureRecognizer(tapGesture)

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

  @objc private func didTapOutside() {
    presentingViewController.dismiss(animated: true)
  }
}

private func calculateFittingHeight(of view: UIView, targetView: UIView) -> CGFloat {
  let targetHeight = view.systemLayoutSizeFitting(
    CGSize(width: targetView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
  ).height

  return min(targetHeight, targetView.bounds.height * Constants.maxHeightRatio)
}

private enum Constants {
  static let maxHeightRatio: CGFloat = 0.8
}
