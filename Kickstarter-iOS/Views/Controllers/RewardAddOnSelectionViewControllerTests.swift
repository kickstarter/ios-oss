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
      |> Reward.lens.localPickup .~ nil

    let noShippingAddOn = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none
      |> Reward.lens.localPickup .~ nil

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [noShippingAddOn]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService) {
        let controller = RewardAddOnSelectionViewController.instantiate()

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
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
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.localPickup .~ nil

    let shippingAddOn = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .unrestricted
      |> Reward.lens.shippingRulesExpanded .~ shippingRules
      |> Reward.lens.localPickup .~ nil

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [shippingAddOn]

    let mockService = MockService(
      fetchShippingRulesResult: .success(shippingRules),
      fetchRewardAddOnsSelectionViewRewardsResult: .success(project)
    )

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService) {
        let controller = RewardAddOnSelectionViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
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

  func testView_EmptyState() {
    let shippingRules = [
      ShippingRule.template
        |> ShippingRule.lens.location .~ .brooklyn,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .canada,
      ShippingRule.template
        |> ShippingRule.lens.location .~ .australia
    ]

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 55)

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shipping.preference .~ .restricted
      |> Reward.lens.id .~ 99
      |> Reward.lens.shippingRules .~ [shippingRule]
      |> Reward.lens.localPickup .~ nil

    let shippingAddOn1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]
      |> Reward.lens.localPickup .~ nil

    let shippingAddOn2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]
      |> Reward.lens.localPickup .~ nil

    let shippingAddOn3 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]
      |> Reward.lens.localPickup .~ nil

    let shippingAddOn4 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]
      |> Reward.lens.localPickup .~ nil

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [
        shippingAddOn1,
        shippingAddOn2,
        shippingAddOn3,
        shippingAddOn4
      ]

    let mockService = MockService(
      fetchShippingRulesResult: .success(shippingRules),
      fetchRewardAddOnsSelectionViewRewardsResult: .success(project)
    )

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService) {
        let controller = RewardAddOnSelectionViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        controller.pledgeShippingLocationViewController(
          PledgeShippingLocationViewController.instantiate(),
          didSelect: shippingRule
        )

        self.scheduler.advance(by: .seconds(1))

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_Error() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.localPickup .~ nil
    let project = Project.template

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .failure(.couldNotParseJSON))

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService) {
        let controller = RewardAddOnSelectionViewController.instantiate()

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_NoShippingWithLocalPickup_Success() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.localPickup .~ .australia
      |> Reward.lens.shipping.preference .~ .local

    let noShippingAddOn = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .australia

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [noShippingAddOn]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    combos(Language.allLanguages, [Device.phone5_8inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: mockService, language: language) {
        let controller = RewardAddOnSelectionViewController.instantiate()

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
