import Foundation
import UIKit

public extension UIPageViewController {
  func ksr_setViewControllers(
    _ viewControllers: [UIViewController]?,
    direction: UIPageViewController.NavigationDirection,
    animated: Bool,
    completion: ((Bool) -> Void)? = nil
  ) {
    func commit() {
      self.setViewControllers(
        viewControllers,
        direction: direction,
        animated: animated,
        completion: completion
      )
    }

    if Thread.isMainThread {
      commit()
    } else {
      DispatchQueue.main.sync {
        commit()
      }
    }
  }
}
