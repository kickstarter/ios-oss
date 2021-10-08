import KsApi
import Library
import UIKit

internal final class ProjectPamphletPagesDataSource: NSObject, UIPageViewControllerDataSource {
  private let viewControllers: [UIViewController]

  internal init(delegate _: UIViewController) {
    self.viewControllers = NavigationSection.allCases.map { navSection in
      switch navSection {
      case .overview:
        let viewController = UIViewController()
        viewController.view.backgroundColor = .red
        return viewController
      case .campaign:
        let viewController = UIViewController()
        viewController.view.backgroundColor = .orange
        return viewController
      case .faq:
        let viewController = UIViewController()
        viewController.view.backgroundColor = .yellow
        return viewController
      case .environmentalCommitments:
        let viewController = UIViewController()
        viewController.view.backgroundColor = .green
        return viewController
      }
    }
  }

  internal func controllerFor(section: NavigationSection) -> UIViewController? {
    guard let index = indexFor(section: section) else { return nil }
    return self.viewControllers[index]
  }

  internal func indexFor(section: NavigationSection) -> Int? {
    return NavigationSection.allCases.firstIndex(of: section)
  }

  internal func pageViewController(
    _: UIPageViewController,
    viewControllerAfter viewController: UIViewController
  ) -> UIViewController? {
    guard let pageIdx = self.viewControllers.firstIndex(of: viewController) else {
      fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
    }

    let nextPageIdx = pageIdx + 1
    guard nextPageIdx < self.viewControllers.count else {
      return nil
    }

    return self.viewControllers[nextPageIdx]
  }

  internal func pageViewController(
    _: UIPageViewController,
    viewControllerBefore viewController: UIViewController
  ) -> UIViewController? {
    guard let pageIdx = self.viewControllers.firstIndex(of: viewController) else {
      fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
    }

    let previousPageIdx = pageIdx - 1
    guard previousPageIdx >= 0 else {
      return nil
    }

    return self.viewControllers[previousPageIdx]
  }
}
