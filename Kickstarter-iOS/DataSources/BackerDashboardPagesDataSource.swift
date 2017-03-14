import KsApi
import Library
import UIKit

internal final class BackerDashboardPagesDataSource: NSObject, UIPageViewControllerDataSource {
  private let viewControllers: [UIViewController]

  internal init(delegate: BackerDashboardViewController, sort: DiscoveryParams.Sort) {
    let backedController = BackerDashboardProjectsViewController()
    backedController.configureWith(delegate: delegate, projectsType: .backed, sort: sort)

    let savedController = BackerDashboardProjectsViewController()
    savedController.configureWith(delegate: delegate, projectsType: .saved, sort: sort)

    self.viewControllers = [backedController, savedController]
  }

  internal func indexFor(controller: UIViewController) -> Int? {
    return self.viewControllers.index(of: controller)
  }

  internal func controllerFor(tab: BackerDashboardTab) -> UIViewController? {
    return self.viewControllers[tab.rawValue]
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
}
