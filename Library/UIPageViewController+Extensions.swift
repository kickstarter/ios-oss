import UIKit

extension UIPageViewController {

  public func isScrollEnabled(_ enabled: Bool) {
    let scrollView = self.view.subviews.filter { $0 is UIScrollView }.first as? UIScrollView
    scrollView?.isScrollEnabled = enabled
  }
}
