import UIKit

extension UIView {
  /// Rounds the corners of the view with a specified corner radius.
  /// - Parameter cornerRadius: The radius to apply to the view's corners. Defaults to `Styles.cornerRadius`.
  public func rounded(with cornerRadius: CGFloat = Styles.cornerRadius) {
    self.clipsToBounds = true
    self.layer.masksToBounds = true
    self.layer.cornerRadius = cornerRadius
  }

  /// Constrains the view to the edges of a parent view with an optional priority.
  ///
  /// This method adds constraints to make the view fill its parent view entirely. You can
  /// specify a custom priority for the constraints if needed.
  ///
  /// - Parameters:
  ///   - parentView: The parent `UIView` to which the current view will be constrained.
  ///   - priority: The priority of the constraints. Defaults to `.required`.
  public func constrainViewToEdges(in parentView: UIView, priority: UILayoutPriority = .required) {
    self.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
      self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
      self.topAnchor.constraint(equalTo: parentView.topAnchor),
      self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
    ]

    constraints.forEach { $0.priority = priority }

    NSLayoutConstraint.activate(constraints)
  }

  public func constrainViewToMargins(in parentView: UIView, priority: UILayoutPriority = .required) {
    self.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      self.leadingAnchor.constraint(equalTo: parentView.layoutMarginsGuide.leadingAnchor),
      self.trailingAnchor.constraint(equalTo: parentView.layoutMarginsGuide.trailingAnchor),
      self.topAnchor.constraint(equalTo: parentView.layoutMarginsGuide.topAnchor),
      self.bottomAnchor.constraint(equalTo: parentView.layoutMarginsGuide.bottomAnchor)
    ]

    constraints.forEach { $0.priority = priority }

    NSLayoutConstraint.activate(constraints)
  }
}
