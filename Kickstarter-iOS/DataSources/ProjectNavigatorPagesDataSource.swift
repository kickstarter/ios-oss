import KsApi
import Library

internal final class ProjectNavigatorPagesDataSource: NSObject, UIPageViewControllerDataSource {

  private let initialProject: Project
  private var playlist: [Project] = []
  private let refTag: RefTag
  private var viewControllers: [UIViewController?] = []

  init(refTag: RefTag, initialPlaylist: [Project], initialProject: Project) {
    self.initialProject = initialProject
    self.playlist = initialPlaylist
    self.refTag = refTag

    super.init()

    self.padControllers(toLength: self.playlist.count)
  }

  internal func initialController() -> UIViewController? {
    return self.playlist.indexOf(self.initialProject).flatMap(self.controllerFor(index:))
  }

  internal func initialPamphletController() -> ProjectPamphletViewController? {
    return self.playlist.indexOf(self.initialProject).flatMap(self.projectPamphletControllerFor(index:))
  }

  internal func controllerFor(index index: Int) -> UIViewController? {
    guard index >= 0 && index < self.playlist.count else { return nil }

    let project = self.playlist[index]
    self.padControllers(toLength: index)

    self.viewControllers[index] = self.viewControllers[index]
      ?? self.createViewController(forProject: project)
    return self.viewControllers[index]
  }

  internal func projectPamphletControllerFor(index index: Int) -> ProjectPamphletViewController? {
    return self.controllerFor(index: index)
      .flatMap { $0 as? UINavigationController }
      .flatMap { $0.viewControllers.first as? ProjectPamphletViewController }
  }

  internal func indexFor(controller controller: UIViewController) -> Int? {
    return self.viewControllers.indexOf { $0 == controller }
  }

  internal func pageViewController(
    pageViewController: UIPageViewController,
    viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

    guard let pageIdx = self.viewControllers.indexOf({ $0 == viewController }) else {
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
    pageViewController: UIPageViewController,
    viewControllerBeforeViewController
    viewController: UIViewController) -> UIViewController? {

    guard let pageIdx = self.viewControllers.indexOf({ $0 == viewController }) else {
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

  private func createViewController(forProject project: Project) -> UIViewController {
    return UINavigationController(
      rootViewController: ProjectPamphletViewController.configuredWith(
        projectOrParam: .left(project),
        refTag: self.refTag
      )
    )
  }

  private func clearViewControllersFarAway(fromIndex index: Int) {
    self.viewControllers.indices
      .filter { abs($0 - index) >= 3 }
      .forEach { idx in
        self.viewControllers[idx] = nil
    }
  }

  private func padControllers(toLength length: Int) {
    guard self.viewControllers.count <= length else { return }

    (self.viewControllers.count...length).forEach { _ in
      self.viewControllers.append(nil)
    }
  }
}
