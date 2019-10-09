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
    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let controller = ManageViewPledgeRewardReceivedViewController.instantiate()
        controller.configureWith(project: .template)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 60

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_Toggle_On() {
    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let project = Project.template
          |> Project.lens.personalization .. Project.Personalization.lens.backing .~ .template

        let controller = ManageViewPledgeRewardReceivedViewController.instantiate()
        controller.configureWith(project: project)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 60

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
