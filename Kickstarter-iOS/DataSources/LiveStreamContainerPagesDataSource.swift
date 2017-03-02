import KsApi
import Library

internal final class LiveStreamContainerPagesDataSource: NSObject {
  fileprivate var viewControllers: [UIViewController]?

  internal func load(viewControllers: [UIViewController]) {
    self.viewControllers = viewControllers
  }

  internal func indexFor(controller: UIViewController) -> Int? {
    return self.viewControllers?.index(of: controller)
  }
}

extension LiveStreamContainerPagesDataSource: UIPageViewControllerDataSource {
  internal func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) ->

    UIViewController? {
      guard let pageIdx = self.viewControllers?.index(of: viewController) else {
        fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
      }

      let previousPageIdx = pageIdx - 1
      guard previousPageIdx >= 0 else {
        return nil
      }

      return self.viewControllers?[previousPageIdx]
  }

  internal func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) ->
    UIViewController? {
      guard let pageIdx = self.viewControllers?.index(of: viewController) else {
        fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
      }

      let nextPageIdx = pageIdx + 1
      guard nextPageIdx < self.viewControllers?.count ?? 0 else {
        return nil
      }

      return self.viewControllers?[nextPageIdx]
  }
}
