import KsApi
import Library

internal final class ProjectNavigatorPagesDataSource: NSObject, UIPageViewControllerDataSource {

  fileprivate let initialProject: Project
  fileprivate var playlist: [Project] = []
  fileprivate let refTag: RefTag
  fileprivate var viewControllers: [UIViewController?] = []

  init(refTag: RefTag, initialPlaylist: [Project]?, initialProject: Project) {
    self.initialProject = initialProject
    self.playlist = initialPlaylist ?? [initialProject]
    self.refTag = refTag

    super.init()

    self.padControllers(toLength: self.playlist.count)
  }

  internal func updatePlaylist(_ playlist: [Project]) {
    self.playlist = playlist

    //self.padControllers(toLength: self.playlist.count)
  }

  internal func initialController() -> UIViewController? {
    return self.playlist.index(of: self.initialProject).flatMap(self.controllerFor(index:))
  }

  internal func initialPamphletController() -> ProjectPamphletViewController? {
    return self.playlist.index(of: self.initialProject).flatMap(self.projectPamphletControllerFor(index:))
  }

  internal func controllerFor(index: Int) -> UIViewController? {
    guard index >= 0 && index < self.playlist.count else { return nil }

    let project = self.playlist[index]
    self.padControllers(toLength: index)

    self.viewControllers[index] = self.viewControllers[index]
      ?? self.createViewController(forProject: project)
    return self.viewControllers[index]
  }

  internal func projectPamphletControllerFor(index: Int) -> ProjectPamphletViewController? {
    return self.controllerFor(index: index)
      .flatMap { $0 as? UINavigationController }
      .flatMap { $0.viewControllers.first as? ProjectPamphletViewController }
  }

  internal func indexFor(controller: UIViewController) -> Int? {
    return self.viewControllers.index { $0 == controller }
  }

  internal func projectFor(controller: UIViewController) -> Project? {
    return self.indexFor(controller: controller).map { self.playlist[$0] }
  }

  internal func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerAfter viewController: UIViewController) -> UIViewController? {

    guard let pageIdx = self.viewControllers.index(where: { $0 == viewController }) else {
      fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
    }

    let nextPageIdx = pageIdx + 1
    guard nextPageIdx < self.playlist.count else {
      return nil
    }

    let project = self.playlist[nextPageIdx]
    self.padControllers(toLength: nextPageIdx)
    self.viewControllers[nextPageIdx] = self.viewControllers[nextPageIdx]
      ?? self.createViewController(forProject: project)

    self.clearViewControllersFarAway(fromIndex: nextPageIdx)

    return self.viewControllers[nextPageIdx]
  }

  internal func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerBefore
    viewController: UIViewController) -> UIViewController? {

    guard let pageIdx = self.viewControllers.index(where: { $0 == viewController }) else {
      fatalError("Couldn't find \(viewController) in \(self.viewControllers)")
    }

    let previousPageIdx = pageIdx - 1
    guard previousPageIdx >= 0 else {
      return nil
    }

    let project = self.playlist[previousPageIdx]
    self.padControllers(toLength: previousPageIdx)
    self.viewControllers[previousPageIdx] = self.viewControllers[previousPageIdx]
      ?? self.createViewController(forProject: project)

    self.clearViewControllersFarAway(fromIndex: previousPageIdx)

    return self.viewControllers[previousPageIdx]
  }

  fileprivate func createViewController(forProject project: Project) -> UIViewController {
    return UINavigationController(
      rootViewController: ProjectPamphletViewController.configuredWith(
        projectOrParam: .left(project),
        refTag: self.refTag
      )
    )
  }

  fileprivate func clearViewControllersFarAway(fromIndex index: Int) {
    self.viewControllers.indices
      .filter { abs($0 - index) >= 3 }
      .forEach { idx in
        self.viewControllers[idx] = nil
    }
  }

  fileprivate func padControllers(toLength length: Int) {
    guard self.viewControllers.count <= length else { return }

    (self.viewControllers.count...length).forEach { _ in
      self.viewControllers.append(nil)
    }
  }
}
