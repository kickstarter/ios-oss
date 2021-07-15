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
  public func handleKeyboardVisibilityDidChange(_ change: Keyboard.Change, insets: UIEdgeInsets = .zero) {
    UIView.animate(
      withDuration: change.duration,
      delay: 0.0,
      options: change.options,
      animations: {
        switch change.notificationName {
        case UIResponder.keyboardWillShowNotification:
          guard let window = self.window else { return }

          // We need to properly calculate how much of the keyboard is taking over the scroll view
          // which could be presented using modal presentation style .formSheet on iPads
          let frameInWindowCoordinates = window.convert(self.frame, from: self.superview)
          let bottomEdgeInWindowCoordinates = window.frame.maxY - frameInWindowCoordinates.maxY
          let bottomInsets = max(insets.bottom, change.frame.height - bottomEdgeInWindowCoordinates)

          self.contentInset.bottom = bottomInsets
          self.verticalScrollIndicatorInsets.bottom = bottomInsets

        case UIResponder.keyboardWillHideNotification:
          self.contentInset = insets
          self.scrollIndicatorInsets = insets

        default:
          return
        }
      }, completion: nil
    )
  }
}
