@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
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

  func testView_Toggle_Off() {
    let data = ManageViewPledgeRewardReceivedViewData(
      project: .template,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .collected
    )

    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let controller = ManageViewPledgeRewardReceivedViewController.instantiate()
        controller.configureWith(data: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 80

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_Toggle_On() {
    let data = ManageViewPledgeRewardReceivedViewData(
      project: .template,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .collected
    )

    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let controller = ManageViewPledgeRewardReceivedViewController.instantiate()
        controller.configureWith(data: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 80

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
