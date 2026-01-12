@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import XCTest

internal final class ProjectNotificationsViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testProjectNotifications() {
    let enabledProject = ProjectNotification.template
      |> ProjectNotification.lens.project.name .~ "Other Project"
      |> ProjectNotification.lens.email .~ true
      |> ProjectNotification.lens.mobile .~ true

    let projectNotifications = [
      ProjectNotification.template,
      enabledProject
    ]

    let service = MockService(fetchProjectNotificationsResponse: projectNotifications)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: service,
        language: language
      ) {
        let vc = ProjectNotificationsViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
