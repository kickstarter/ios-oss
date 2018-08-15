import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi

internal final class ProjectNotificationsViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testProjectNotifications() {
    let enabledProject = ProjectNotification.template
      |> ProjectNotification.lens.project.name .~ "Other Project"
      |> ProjectNotification.lens.email .~ true
      |> ProjectNotification.lens.mobile .~ true

    let projectNotifications = [ProjectNotification.template,
                                enabledProject]

    let service = MockService(fetchProjectNotificationsResponse: projectNotifications)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: service,
                      language: language) {
        let vc = ProjectNotificationsViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
