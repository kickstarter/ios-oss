import UIKit

extension UIView {
  public func constrainEdges(to view: UIView, priority: UILayoutPriority = .required) {
    self.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      self.topAnchor.constraint(equalTo: view.topAnchor),
      self.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]

    constraints.forEach { $0.priority = priority }

    NSLayoutConstraint.activate(constraints)
  }
}
