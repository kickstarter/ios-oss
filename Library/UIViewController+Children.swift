import UIKit

/// A helper extension for adding child controllers to a containing view controller.
/// Handles appearance transitions and adding the child controller's view to the view hierarchy.
extension UIViewController {
  /// A convenient helper method for adding a child view controller to a container, then adding its view to the parent's view hierarchy.
  /// - Parameters:
  ///   - controller: the child view controller
  ///   - topLayoutAnchor: The child view controller's top anchor will be constrained to this anchor
  ///   - leftAnchor: The child view controller's left anchor will be constrained to this anchor
  ///   - rightAnchor: The child view controller's right anchor will be constrained to this anchor
  ///   - bottomAnchor: The child view controller's bottom anchor will be constrained to this anchor
  func displayChildViewController(
    _ controller: UIViewController,
    constrainedToTopAnchor topLayoutAnchor: NSLayoutYAxisAnchor?,
    leftAnchor: NSLayoutXAxisAnchor?,
    rightAnchor: NSLayoutXAxisAnchor?,
    bottomAnchor: NSLayoutYAxisAnchor?
  ) {
    guard let childView = controller.view else {
      return
    }

    controller.beginAppearanceTransition(true, animated: true)

    addChild(controller)

    self.view.addSubview(childView)

    childView.translatesAutoresizingMaskIntoConstraints = false

    if let topLayoutAnchor {
      childView.topAnchor.constraint(equalTo: topLayoutAnchor).isActive = true
    }

    if let leftAnchor {
      childView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }

    if let rightAnchor {
      childView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    if let bottomAnchor {
      childView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    controller.didMove(toParent: self)

    controller.endAppearanceTransition()
  }

  /// A convenient helper method for adding a child view controller to a container, then adding its view to the parent's view hierarchy.
  /// The child's view will be constrained to the `safeAreaLayoutGuide` of the parent.
  /// - Parameters:
  ///   - controller: the child view controller
  func displayChildViewController(_ controller: UIViewController) {
    self.displayChildViewController(
      controller,
      constrainedToTopAnchor: self.view.safeAreaLayoutGuide.topAnchor,
      leftAnchor: self.view.safeAreaLayoutGuide.leftAnchor,
      rightAnchor: self.view.safeAreaLayoutGuide.rightAnchor,
      bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor
    )
  }

  /// A convenient helper method for removing a child view controller from its parent.
  /// - Parameters:
  ///   - controller: the child view controller

  func stopDisplayingChildViewController(_ controller: UIViewController) {
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
