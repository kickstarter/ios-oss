import UIKit

extension UIScrollView {

  /**
   Scrolls to the top. If the scroll view happens to be a table view, we try scrolling to the (0, 0)
   index path, and otherwise we just set the content offset directly.
   */
  public func scrollToTop() {
    if let tableView = self as? UITableView,
      tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {

      tableView.scrollToRow(at: .init(row: 0, section: 0),
                                       at: .top,
                                       animated: true)

    } else {
      self.setContentOffset(CGPoint(x: 0.0, y: -self.contentInset.top), animated: true)
    }
  }
}
