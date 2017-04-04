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

  internal func indexFor(tab: BackerDashboardTab) -> Int? {
    return BackerDashboardTab.allTabs.index(of: tab)
  }

  internal func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerAfter viewController: UIViewController) -> UIViewController? {

    return nil
  }

  internal func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerBefore viewController: UIViewController) -> UIViewController? {

    return nil
  }

  private func tabFor(controller: UIViewController) -> BackerDashboardTab? {
    guard let index = self.viewControllers.index(of: controller) else { return nil }

    return BackerDashboardTab.allTabs[index]
  }
}
