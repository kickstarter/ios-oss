import Library
import Prelude
import UIKit

/**
 SheetOverlayViewController is intended to be used as a container for another view controller
 that renders as a "sheet" or "card" that partially covers the content beneath it.
 */

final class SheetOverlayViewController: UIViewController {
  // MARK: - Properties

  private let childViewController: UIViewController
  private let offset: CGFloat
  private let transitionAnimator = SheetOverlayTransitionAnimator()

  init(child: UIViewController, offset: CGFloat = 45.0) {
    self.childViewController = child
    self.offset = offset

    super.init(nibName: nil, bundle: nil)

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      _ = self
        |> \.modalPresentationStyle .~ .overCurrentContext
        |> \.modalTransitionStyle .~ .crossDissolve
    } else {
      _ = self
        |> \.modalPresentationStyle .~ .custom
        |> \.transitioningDelegate .~ self
    }
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.addChild(self.childViewController)
    self.configure(childView: self.childViewController.view, offset: self.offset)

    self.childViewController.didMove(toParent: self)

    _ = self.view
      |> \.backgroundColor .~ UIColor.ksr_soft_black.withAlphaComponent(0.8)
  }

  private func configure(childView: UIView, offset: CGFloat) {
    _ = (childView, self.view)
      |> ksr_addSubviewToParent()

    _ = childView
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    _ = childView.layer
      |> checkoutLayerCardRoundedStyle
      |> \.masksToBounds .~ true
      |> \.maskedCorners .~ [.layerMaxXMinYCorner, .layerMinXMinYCorner]

    let portraitWidth: CGFloat = min(self.view.bounds.height, self.view.bounds.width)

    NSLayoutConstraint.activate([
      childView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      childView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      childView.widthAnchor.constraint(equalToConstant: portraitWidth),
      childView.topAnchor.constraint(
        equalTo: self.view.topAnchor,
        constant: offset
      )
    ])
  }
}

extension SheetOverlayViewController: UIViewControllerTransitioningDelegate {
  func animationController(
    forPresented _: UIViewController, presenting _: UIViewController,
    source _: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    return self.transitionAnimator
  }

  func animationController(forDismissed _: UIViewController) ->
    UIViewControllerAnimatedTransitioning? {
    return self.transitionAnimator
  }
}
