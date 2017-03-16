import KsApi
import Library
import UIKit

internal final class BackerDashboardPagesDataSource: NSObject, UIPageViewControllerDataSource {
  private let viewControllers: [UIViewController]

  internal init(delegate: UIViewController, sort: DiscoveryParams.Sort) {
    let backedController = BackerDashboardProjectsViewController()
    let savedController = BackerDashboardProjectsViewController()

    if let delegate = delegate as? BackerDashboardProjectsViewControllerDelegate {
      backedController.configureWith(delegate: delegate, projectsType: .backed, sort: sort)
      savedController.configureWith(delegate: delegate, projectsType: .saved, sort: sort)
    }

    self.viewControllers = [backedController, savedController]
  }

  internal func controllerFor(tab: BackerDashboardTab) -> UIViewController? {
    return self.viewControllers[tab.rawValue]
  }

  internal func scrollToProject(at row: Int, in controller: UIViewController) {
    guard let currentTab = tabFor(controller: controller) else { return }

    switch currentTab {
    case .backed, .saved:
      if let controller = controller as? BackerDashboardProjectsViewController {
        controller.scrollToProject(at: row)
      }
    }
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

    return BackerDashboardTab(rawValue: index)
  }
}
