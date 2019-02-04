import UIKit

extension UITableView {
  public func setConstrained(headerView: UIView) {
    if self.tableHeaderView != headerView {
      headerView.translatesAutoresizingMaskIntoConstraints = false

      self.tableHeaderView = headerView

      NSLayoutConstraint.activate([
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor)
      ])
    }
  }
}
