@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
import Library
@testable import LibraryTestHelpers
import Prelude
import SnapshotTesting
import XCTest

internal final class ProjectPageNavigationTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testNavigationBar_Unwatched_Success() {
    combos([Language.en], [Device.phone4inch]).forEach { _, device in
      let navigation = ProjectPageNavigation()

      let project = .template |> Project.lens.personalization.isStarred .~ false

      let watchValue = WatchProjectValue(
        project: project,
        context: .project,
        discoveryParams: nil
      )

      navigation.configureWatchProject(with: watchValue)
      navigation.viewDidLoad()

      let (parent, _) = traitControllers(
        device: device,
        orientation: .portrait,
        child: viewControllerWithNavigation(navigation)
      )

      parent.view.frame.size.height = 44

      scheduler.run()

      assertSnapshot(matching: parent.view, as: .image, named: "unwatched")
    }
  }

  func testNavigationBar_Watched_Success() {
    combos([Language.en], [Device.phone4inch]).forEach { _, device in
      let navigation = ProjectPageNavigation()

      let project = .template |> Project.lens.personalization.isStarred .~ true

      let watchValue = WatchProjectValue(
        project: project,
        context: .project,
        discoveryParams: nil
      )

      navigation.configureWatchProject(with: watchValue)
      navigation.viewDidLoad()

      let (parent, _) = traitControllers(
        device: device,
        orientation: .portrait,
        child: viewControllerWithNavigation(navigation)
      )

      parent.view.frame.size.height = 44

      scheduler.run()

      assertSnapshot(matching: parent.view, as: .image, named: "watched")
    }
  }

  private func viewControllerWithNavigation(_ navigation: ProjectPageNavigation) -> UIViewController {
    let vc = UIViewController()
    vc.navigationItem.leftBarButtonItem = navigation.closeButton
    vc.navigationItem.rightBarButtonItems = navigation.rightBarButtonItems
    vc.navigationItem.standardAppearance = UINavigationBarAppearance.projectPageNavigationBarAppearance

    return UINavigationController(rootViewController: vc)
  }
}
