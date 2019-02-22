import UIKit

public extension UIView {
  func constrainEdges(to view: UIView) {
    self.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      self.topAnchor.constraint(equalTo: view.topAnchor),
      self.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
  }

  func addSubviewConstrainedToMargins(_ view: UIView) {
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
