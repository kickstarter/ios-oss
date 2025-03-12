import UIKit

/// A helper extension for adding child controllers to a containing view controller.
/// Handles appearance transitions and adding the child controller's view to the view hierarchy.
extension UIViewController {
  /// A convenient helper method for adding a child view controller to a container, then adding its view to the parent's view hierarchy.
  /// - Parameters:
  ///   - controller: the child view controller
  ///   - constraints: (Inactive) constraints which attach the child view controller to its parent view controller. Will be activated by calling this method.
  public func displayChildViewController(
    _ controller: UIViewController,
    withConstraints constraints: [NSLayoutConstraint]
  ) {
    guard let childView = controller.view else {
      return
    }

    controller.beginAppearanceTransition(true, animated: true)

    addChild(controller)

    self.view.addSubview(childView)

    childView.translatesAutoresizingMaskIntoConstraints = false

    constraints.forEach { constraint in
      constraint.isActive = true
    }

    controller.didMove(toParent: self)

    controller.endAppearanceTransition()
  }

  /// A convenient helper method for adding a child view controller to a container, then adding its view to the parent's view hierarchy.
  /// The child's view will be constrained to the `safeAreaLayoutGuide` of the parent.
  /// - Parameters:
  ///   - controller: the child view controller
  public func displayChildViewController(_ controller: UIViewController) {
    self.displayChildViewController(
      controller,
      withConstraints: [
        self.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: controller.view.topAnchor),
        self.view.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: controller.view.leftAnchor),
        self.view.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: controller.view.rightAnchor),
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
      ]
    )
  }

  /// A convenient helper method for removing a child view controller from its parent.
  /// - Parameters:
  ///   - controller: the child view controller

  public func stopDisplayingChildViewController(_ controller: UIViewController) {
    guard let parent = controller.parent,
          parent == self else {
      return
    }

    controller.beginAppearanceTransition(false, animated: true)

    controller.willMove(toParent: nil)
    for constraint in controller.view.constraints {
      constraint.isActive = false
    }
    controller.view.removeFromSuperview()
    controller.removeFromParent()

    controller.endAppearanceTransition()
  }
}
