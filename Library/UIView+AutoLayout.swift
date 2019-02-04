import UIKit

extension UIView {
  public func constrainEdges(to view: UIView) {
    self.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      self.topAnchor.constraint(equalTo: view.topAnchor),
      self.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}
