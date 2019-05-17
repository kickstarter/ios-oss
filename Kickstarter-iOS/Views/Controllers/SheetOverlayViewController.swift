import UIKit
import Library
import Prelude

/**
 SheetOverlayViewController is intended to be used as a container for another view controller
 that renders as a "sheet" or "card" that partially covers the content beneath it.
 */

final class SheetOverlayViewController: UIViewController {
  // MARK: - Properties

  private let childViewController: UIViewController
  private let offset: CGFloat
  private let transitionAnimator = SheetOverlayTransitionAnimator()

  init(childViewController: UIViewController, offset: CGFloat = 45.0) {
    self.childViewController = childViewController
    self.offset = offset

    super.init(nibName: nil, bundle: nil)

    _ = self
      |> \.modalPresentationStyle .~ .custom
      |> \.transitioningDelegate .~ self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.addChild(self.childViewController)
    self.configureChildView(view: self.childViewController.view, offset: self.offset)

    self.childViewController.didMove(toParent: self)
  }

  private func configureChildView(view: UIView, offset: CGFloat) {
    _ = (view, self.view)
      |> ksr_addSubviewToParent()

    _ = view
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    _ = view.layer
      |> checkoutLayerCardStyleRounded
      |> \.masksToBounds .~ true
      |> \.maskedCorners .~ [.layerMaxXMinYCorner, .layerMinXMinYCorner]

    let isRegular = UIScreen.main.traitCollection.isRegularRegular
    let portraitWidth = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)

    NSLayoutConstraint.activate([view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                 view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                                 view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: offset)])

    if isRegular {
      view.widthAnchor.constraint(equalToConstant: portraitWidth).isActive = true
    } else {
      view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    }
  }
}

extension SheetOverlayViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self.transitionAnimator
  }

  func animationController(forDismissed dismissed: UIViewController) ->
    UIViewControllerAnimatedTransitioning? {
    return self.transitionAnimator
  }
}
