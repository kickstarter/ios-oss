@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class RewardAddOnSelectionViewControllerTests: TestCase {
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

  func testView_NoShipping() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
    let project = Project.template

    let noShippingAddOn = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .noShipping

    let env = RewardAddOnSelectionViewEnvelope.template
      |> \.project.addOns .~ (
        .template |> \.nodes .~ [noShippingAddOn]
      )

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(env))

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService) {
        let controller = RewardAddOnSelectionViewController.instantiate()
        controller.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_Shipping() {
    let shippingRules = [
      ShippingRule.template
        |> ShippingRule.lens.location .~ .brooklyn,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .canada,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .australia
    ]

    let reward = Reward.template
      |> Reward.lens.shipping .~ (
        .template |> Reward.Shipping.lens.enabled .~ true
      )
      |> Reward.lens.shipping.preference .~ .unrestricted
    let project = Project.template

    let shippingAddOn = RewardAddOnSelectionViewEnvelope.Project.Reward.template
      |> \.shippingPreference .~ .unrestricted

    let env = RewardAddOnSelectionViewEnvelope.template
      |> \.project.addOns .~ (
        .template |> \.nodes .~ [shippingAddOn]
      )

    let mockService = MockService(
      fetchShippingRulesResult: .success(shippingRules),
      fetchRewardAddOnsSelectionViewRewardsResult: .success(env)
    )

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService) {
        let controller = RewardAddOnSelectionViewController.instantiate()
        controller.configureWith(project: project, reward: reward, refTag: nil, context: .pledge)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        controller.pledgeShippingLocationViewController(
          PledgeShippingLocationViewController.instantiate(),
          didSelect: .template
        )

        self.scheduler.advance(by: .seconds(1))

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
