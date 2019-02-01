import UIKit

extension UITableView {
  public func setConstrained(headerView: UIView) {
    headerView.translatesAutoresizingMaskIntoConstraints = false

    headerView.layoutIfNeeded()
    self.tableHeaderView = headerView

    NSLayoutConstraint.activate([
      headerView.widthAnchor.constraint(equalTo: self.widthAnchor)
    ])
  }
}
