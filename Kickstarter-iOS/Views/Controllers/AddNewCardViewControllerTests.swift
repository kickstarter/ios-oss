import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library

final class AddNewCardViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  func testAddNewCard() {
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(language: language) {
        let controller = AddNewCardViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
