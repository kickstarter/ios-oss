@testable import Kickstarter_Framework
@testable import Library
import UIKit

final class ManageViewPledgeRewardReceivedViewControllerTests: TestCase {
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

  func testView() {
    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    let toggleStates = [true, false]
    combos([Language.en], devices, toggleStates).forEach { language, device, toggleState in
      withEnvironment(language: language) {
        let controller = ManageViewPledgeRewardReceivedViewController.instantiate()
        controller.toggle.setOn(toggleState, animated: false)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 60

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(language)_device_\(device)_toggle_\(toggleState)"
        )
      }
    }
  }
}
