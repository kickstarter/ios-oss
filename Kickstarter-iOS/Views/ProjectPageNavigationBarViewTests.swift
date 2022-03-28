@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import XCTest

internal final class ProjectPageNavBarViewTests: TestCase {
  override func setUp() {
    super.setUp()

    UIView.setAnimationsEnabled(false)
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testNavigationBar_Unwatched_Success() {
    combos([Language.en], [Device.phone4inch]).forEach { _, device in
      let view = ProjectPageNavigationBarView(frame: .zero)
        |> \.translatesAutoresizingMaskIntoConstraints .~ false

      let project = .template |> Project.lens.personalization.isStarred .~ false

      let watchValue = WatchProjectValue(
        project: project,
        context: .projectPage,
        discoveryParams: nil
      )

      view.configureWatchProject(with: watchValue)
      view.viewDidLoad()

      let (parent, _) = traitControllers(
        device: device,
        orientation: .portrait,
        child: wrappedViewController(subview: view, device: device)
      )

      parent.view.frame.size.height = 44

      scheduler.run()

      FBSnapshotVerifyView(parent.view, identifier: "unwatched")
    }
  }

  func testNavigationBar_Watched_Success() {
    combos([Language.en], [Device.phone4inch]).forEach { _, device in
      let view = ProjectPageNavigationBarView(frame: .zero)
        |> \.translatesAutoresizingMaskIntoConstraints .~ false

      let project = .template |> Project.lens.personalization.isStarred .~ true

      let watchValue = WatchProjectValue(
        project: project,
        context: .projectPage,
        discoveryParams: nil
      )

      view.configureWatchProject(with: watchValue)
      view.viewDidLoad()

      let (parent, _) = traitControllers(
        device: device,
        orientation: .portrait,
        child: wrappedViewController(subview: view, device: device)
      )

      parent.view.frame.size.height = 44

      scheduler.run()

      FBSnapshotVerifyView(parent.view, identifier: "watched")
    }
  }

  private func wrappedViewController(subview: UIView, device: Device) -> UIViewController {
    let controller = UIViewController(nibName: nil, bundle: nil)
    let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

    controller.view.addSubview(subview)

    NSLayoutConstraint.activate([
      subview.leadingAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.leadingAnchor),
      subview.topAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.topAnchor),
      subview.trailingAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.trailingAnchor),
      subview.bottomAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.bottomAnchor)
    ])

    return parent
  }
}
