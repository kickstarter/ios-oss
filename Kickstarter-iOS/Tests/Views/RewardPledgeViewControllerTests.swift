// swiftlint:disable type_name
import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class RewardPledgeViewControllerTests: TestCase {
  private let cosmicSurgery = Project.cosmicSurgery
    |> Project.lens.state .~ .live
  private let cosmicReward = Project.cosmicSurgery.rewards.last!
    |> Reward.lens.shipping.enabled .~ true

  override func setUp() {
    super.setUp()

    UIView.setAnimationsEnabled(false)

    AppEnvironment.pushEnvironment(
      mainBundle: NSBundle.framework,
      apiService: MockService(
        fetchShippingRulesResponse: [
          .template |> ShippingRule.lens.location .~ .usa,
          .template |> ShippingRule.lens.location .~ .canada,
          .template |> ShippingRule.lens.location .~ .greatBritain,
          .template |> ShippingRule.lens.location .~ .australia,
        ]
      )
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  func testPledge_AllLanguages() {
    let project = self.cosmicSurgery
    let reward = self.cosmicReward |> Reward.lens.rewardsItems .~ []

    let devices = [Device.phone4inch, Device.phone4_7inch]
    let languages = Language.allLanguages
    combos(languages, devices).forEach { language, device in
      withEnvironment(language: language) {

        let vc = RewardPledgeViewController.configuredWith(project: project, reward: reward)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height -= 64

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testExpandReward() {
    let project = self.cosmicSurgery
    let reward = self.cosmicReward

    let vc = RewardPledgeViewController.configuredWith(project: project, reward: reward)
    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
    parent.view.frame.size.height = 870

    vc.viewModel.inputs.descriptionLabelTapped()
    self.scheduler.run()

    FBSnapshotVerifyView(vc.view)
  }

  func testPledge_NoShipping() {
    let project = self.cosmicSurgery
    let reward = self.cosmicReward
      |> Reward.lens.rewardsItems .~ []
      |> Reward.lens.shipping.enabled .~ false

    let vc = RewardPledgeViewController.configuredWith(project: project, reward: reward)
    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
    parent.view.frame.size.height -= 64

    self.scheduler.run()

    FBSnapshotVerifyView(vc.view)
  }

  func testPledge_NoApplePay() {
    let project = self.cosmicSurgery
    let reward = self.cosmicReward |> Reward.lens.rewardsItems .~ []

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let vc = RewardPledgeViewController.configuredWith(
          project: project, reward: reward, applePayCapable: false
        )
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height -= 64

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")
      }
    }
  }
}
