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

  public func addSubviewConstrainedToMargins(_ view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false

    self.addSubview(view)

    NSLayoutConstraint.activate([
      self.layoutMarginsGuide.topAnchor.constraint(equalTo: view.topAnchor),
      self.layoutMarginsGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      self.layoutMarginsGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      self.layoutMarginsGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor)
      ])
  }
}
