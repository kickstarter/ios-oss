import KsApi
import UIKit

internal final class DiscoveryPagesDataSource: NSObject, UIPageViewControllerDataSource {
  private let viewControllers: [UIViewController]
  private let sorts: [DiscoveryParams.Sort]

  internal init(sorts: [DiscoveryParams.Sort]) {
    self.sorts = sorts

    let storyboard = UIStoryboard(name: "Discovery", bundle: NSBundle(forClass: self.dynamicType))

    self.viewControllers = sorts.map { sort in
      let vc = storyboard.instantiateViewControllerWithIdentifier("DiscoveryPageViewController")
      guard let page = vc as? DiscoveryPageViewController else {
        fatalError("Couldn't instantiate DiscoveryPageViewController.")
      }

      page.configureWith(sort: sort)
      return page
    }
  }

  internal func load(filter filter: DiscoveryParams) {
    self.viewControllers
      .flatMap { $0 as? DiscoveryPageViewController }
      .forEach { $0.change(filter: filter) }
  }

  internal func indexFor(controller controller: UIViewController) -> Int? {
    return self.viewControllers.indexOf(controller)
  }

  internal func sortFor(controller controller: UIViewController) -> DiscoveryParams.Sort? {
    return self.indexFor(controller: controller).map { self.sorts[$0] }
  }

  internal func controllerFor(index index: Int) -> UIViewController? {
    guard index >= 0 && index < self.viewControllers.count else { return nil }
    return self.viewControllers[index]
  }

  internal func controllerFor(sort sort: DiscoveryParams.Sort) -> UIViewController? {
    guard let index = self.sorts.indexOf(sort) else { return nil }
    return self.viewControllers[index]
  }

  internal func pageViewController(
    pageViewController: UIPageViewController,
    viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

    guard let pageIdx = self.viewControllers.indexOf(viewController) else {
      fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
    }

    let nextPageIdx = pageIdx + 1
    guard nextPageIdx < self.viewControllers.count else {
      return nil
    }

    return self.viewControllers[nextPageIdx]
  }

  internal func pageViewController(
    pageViewController: UIPageViewController,
    viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

    guard let pageIdx = self.viewControllers.indexOf(viewController) else {
      fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
    }

    let previousPageIdx = pageIdx - 1
    guard previousPageIdx >= 0 else {
      return nil
    }

    return self.viewControllers[previousPageIdx]
  }
}
