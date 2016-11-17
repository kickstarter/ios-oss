import UIKit

extension UIScrollView {

  /**
   Scrolls to the top. If the scroll view happens to be a table view, we try scrolling to the (0, 0)
   index path, and otherwise we just set the content offset directly.
   */
  public func scrollToTop() {
    if let tableView = self as? UITableView
      where tableView.numberOfSections > 0 && tableView.numberOfRowsInSection(0) > 0 {

      tableView.scrollToRowAtIndexPath(.init(forRow: 0, inSection: 0),
                                       atScrollPosition: .Top,
                                       animated: true)

    } else {
      self.setContentOffset(CGPoint(x: 0.0, y: -self.contentInset.top), animated: true)
    }
  }
}
