import KsApi
import UIKit

internal final class DiscoveryPagesDataSource: NSObject, UIPageViewControllerDataSource {
  fileprivate let viewControllers: [UIViewController]
  fileprivate let sorts: [DiscoveryParams.Sort]

  internal init(sorts: [DiscoveryParams.Sort]) {
    self.sorts = sorts
    self.viewControllers = sorts.map(DiscoveryPageViewController.configuredWith(sort:))
  }

  internal func load(filter: DiscoveryParams) {
    self.viewControllers
      .compactMap { $0 as? DiscoveryPageViewController }
      .forEach { $0.change(filter: filter) }
  }

  internal func indexFor(controller: UIViewController) -> Int? {
    return self.viewControllers.index(of: controller)
  }

  internal func sortFor(controller: UIViewController) -> DiscoveryParams.Sort? {
    return self.indexFor(controller: controller).map { self.sorts[$0] }
  }

  internal func controllerFor(index: Int) -> UIViewController? {
    guard index >= 0 && index < self.viewControllers.count else { return nil }
    return self.viewControllers[index]
  }

  internal func controllerFor(sort: DiscoveryParams.Sort) -> UIViewController? {
    guard let index = self.sorts.index(of: sort) else { return nil }
    return self.viewControllers[index]
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
}
