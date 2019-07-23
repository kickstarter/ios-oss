import UIKit

extension UIScrollView {
  /**
   Scrolls to the top. If the scroll view happens to be a table view, we try scrolling to the (0, 0)
   index path, and otherwise we just set the content offset directly.
   */
  public func scrollToTop() {
    if let tableView = self as? UITableView,
      tableView.numberOfSections > 0, tableView.numberOfRows(inSection: 0) > 0 {
      tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)

    } else {
      self.setContentOffset(CGPoint(x: 0.0, y: -self.contentInset.top), animated: true)
    }
  }

  /**
   Adjusts its contentInset according to Keyboard visibility.
   */
  public func handleKeyboardVisibilityDidChange(_ change: Keyboard.Change) {
    UIView.animate(
      withDuration: change.duration,
      delay: 0.0,
      options: change.options,
      animations: { [weak self] in
        switch change.notificationName {
        case UIResponder.keyboardWillShowNotification:
          self?.contentInset.bottom = change.frame.height
        case UIResponder.keyboardWillHideNotification:
          self?.contentInset.bottom = .zero
        default:
          return
        }
      }, completion: nil
    )
  }
}
