import Foundation
import UIKit

public extension UIRefreshControl {
  func ksr_beginRefreshing() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
      if let scrollView = self.superview as? UIScrollView, scrollView.contentOffset.y == 0 {
        scrollView.setContentOffset(
          .init(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y - self.frame.height),
          animated: true
        )
      }

      self.beginRefreshing()
    }
  }
}
