import Foundation

@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude

internal final class EditorialProjectsViewControllerTests: TestCase {
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

  func testView_LightsOn() {
    combos(Language.allLanguages, Device.allCases).forEach {
      language, device in
      withEnvironment(language: language) {
        let controller = EditorialProjectsViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        controller.configure(with: .lightsOn)
        controller.view.layoutIfNeeded()
        controller.discoveryPageViewController.tableView.layoutIfNeeded()
        controller.discoveryPageViewController.tableView.reloadData()

        self.scheduler.run()

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
