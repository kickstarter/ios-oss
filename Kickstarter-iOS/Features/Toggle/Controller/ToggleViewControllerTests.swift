@testable import Kickstarter_Framework
@testable import Library
import UIKit

final class ToggleViewControllerTests: TestCase {
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
    let devices = [Device.phone4_7inch, Device.pad]
    combos([Language.en], devices).forEach { language, device in
      withEnvironment(language: language) {
        let controller = ToggleViewController.instantiate()
        controller.titleLabel.text = "Title for testing purposes only"
        controller.toggle.setOn(true, animated: false)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 60

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_LargerText() {
    UITraitCollection.allCases.forEach { additionalTraits in
      let controller = ToggleViewController.instantiate()
      controller.titleLabel.text = "Title for testing purposes only"
      controller.toggle.setOn(true, animated: false)

      let (parent, _) = traitControllers(child: controller, additionalTraits: additionalTraits)

      parent.view.frame.size.height = 300

      FBSnapshotVerifyView(
        parent.view, identifier: "trait_\(additionalTraits.preferredContentSizeCategory.rawValue)"
      )
    }
  }
}
