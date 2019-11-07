@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class ManagePledgeViewControllerTests: TestCase {
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
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {
        let reward = Reward.template
          |> Reward.lens.shipping.enabled .~ true
        let backing = Backing.template
          |> Backing.lens.reward .~ reward
        let backedProject = Project.cosmicSurgery
          |> Project.lens.personalization.backing .~ backing

        let controller = ManagePledgeViewController.instantiate()
        controller.configureWith(project: backedProject)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_200

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_NoReward_ApplePay() {
    let language = Language.en
    let device = Device.phone4_7inch

    withEnvironment(language: language) {
      let reward = Reward.noReward

      let backing = Backing.template
        |> Backing.lens.amount .~ 10
        |> Backing.lens.locationId .~ nil
        |> Backing.lens.shippingAmount .~ nil
        |> Backing.lens.rewardId .~ nil
        |> Backing.lens.reward .~ reward
        |> Backing.lens.paymentSource .~ Backing.PaymentSource.applePay

      let backedProject = Project.cosmicSurgery
        |> Project.lens.personalization.backing .~ backing

      let controller = ManagePledgeViewController.instantiate()
      controller.configureWith(project: backedProject)
      let (parent, _) = traitControllers(
        device: device,
        orientation: .portrait,
        child: controller
      )

      self.scheduler.run()

      FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
    }
  }

  func testView_GooglePay() {
    let language = Language.en
    let device = Device.phone4_7inch

    withEnvironment(language: language) {
      let reward = Reward.template
        |> Reward.lens.shipping.enabled .~ true

      let backing = Backing.template
        |> Backing.lens.reward .~ reward
        |> Backing.lens.paymentSource .~ Backing.PaymentSource.googlePay

      let backedProject = Project.cosmicSurgery
        |> Project.lens.personalization.backing .~ backing

      let controller = ManagePledgeViewController.instantiate()
      controller.configureWith(project: backedProject)
      let (parent, _) = traitControllers(
        device: device,
        orientation: .portrait,
        child: controller
      )
      self.scheduler.run()

      FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
    }
  }
}
