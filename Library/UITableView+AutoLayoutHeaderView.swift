import UIKit

extension UITableView {
  public func setConstrained(headerView: UIView) {
    headerView.translatesAutoresizingMaskIntoConstraints = false

    headerView.layoutIfNeeded()

    NSLayoutConstraint.activate([
      headerView.widthAnchor.constraint(equalTo: self.widthAnchor)
    ])
  }
}
