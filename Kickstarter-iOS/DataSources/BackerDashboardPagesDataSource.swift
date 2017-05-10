import KsApi
import Library
import UIKit

internal final class BackerDashboardPagesDataSource: NSObject, UIPageViewControllerDataSource {
  private let viewControllers: [UIViewController]

  internal init(delegate: UIViewController, sort: DiscoveryParams.Sort) {
    let backedController = BackerDashboardProjectsViewController.configuredWith(projectsType: .backed,
                                                                                sort: sort)

    let savedController = BackerDashboardProjectsViewController.configuredWith(projectsType: .saved,
                                                                               sort: sort)

    self.viewControllers = BackerDashboardTab.allTabs.map { tab in
      switch tab {
      case .backed: return backedController
      case .saved:  return savedController
      }
    }
  }

  internal func controllerFor(tab: BackerDashboardTab) -> UIViewController? {
    guard let index = indexFor(tab: tab) else { return nil }
    return self.viewControllers[index]
  }

  internal func indexFor(controller: UIViewController) -> Int? {
    return self.viewControllers.index(of: controller)
  }

  internal func indexFor(tab: BackerDashboardTab) -> Int? {
    return BackerDashboardTab.allTabs.index(of: tab)
  }

  internal func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerAfter viewController: UIViewController) -> UIViewController? {

    guard let pageIdx = self.viewControllers.index(of: viewController) else {
      fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
    }

    let nextPageIdx = pageIdx + 1
    guard nextPageIdx < self.viewControllers.count else {
      return nil
    }

    return self.viewControllers[nextPageIdx]
  }

  internal func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerBefore viewController: UIViewController) -> UIViewController? {

    guard let pageIdx = self.viewControllers.index(of: viewController) else {
      fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
    }

    let previousPageIdx = pageIdx - 1
    guard previousPageIdx >= 0 else {
      return nil
    }

    return self.viewControllers[previousPageIdx]
  }

  private func tabFor(controller: UIViewController) -> BackerDashboardTab? {
    guard let index = self.viewControllers.index(of: controller) else { return nil }

    return BackerDashboardTab.allTabs[index]
  }
}
