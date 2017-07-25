import KsApi
import Library

internal final class LiveStreamContainerPagesDataSource: NSObject {
  fileprivate var viewControllers: [UIViewController] = []
  fileprivate var pages: [LiveStreamContainerPage] = []

  internal func load(pages: [LiveStreamContainerPage]) {
    self.pages = pages

    self.viewControllers = pages.map { page -> UIViewController in
      switch page {
      case .chat(let project, let liveStreamEvent):
        return LiveStreamChatViewController.configuredWith(
          project: project,
          liveStreamEvent: liveStreamEvent
        )
      case .info(let project, let liveStreamEvent, let refTag, let presentedFromProject):
        return LiveStreamEventDetailsViewController.configuredWith(
          project: project,
          liveStreamEvent: liveStreamEvent,
          refTag: refTag,
          presentedFromProject: presentedFromProject
        )
      }
    }
  }

  internal func index(forController controller: UIViewController) -> Int? {
    return self.viewControllers.index(of: controller)
  }

  internal func controller(forPage page: LiveStreamContainerPage) -> UIViewController? {
    return self.pages.index(of: page).map { self.viewControllers[$0] }
  }

  internal func controller(forIndex index: Int) -> UIViewController? {
    guard index >= 0 && index < self.viewControllers.count else { return nil }
    return self.viewControllers[index]
  }

  internal func page(forController controller: UIViewController) -> LiveStreamContainerPage? {
    return self.viewControllers.index(of: controller).map { self.pages[$0] }
  }
}

extension LiveStreamContainerPagesDataSource: UIPageViewControllerDataSource {
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
}
