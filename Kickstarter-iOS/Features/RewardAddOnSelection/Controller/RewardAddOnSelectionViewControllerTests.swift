@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

final class RewardAddOnSelectionViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.hasAddOns .~ true

    let noShippingAddOn = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [noShippingAddOn]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    let darkModeOn = MockRemoteConfigClient()
    darkModeOn.features = [
      RemoteConfigFeature.darkModeEnabled.rawValue: true,
      RemoteConfigFeature.newDesignSystem.rawValue: true
    ]

    orthogonalCombos(
      Language.allLanguages,
      Device.allCases,
      [UIUserInterfaceStyle.light, UIUserInterfaceStyle.dark]
    ).forEach { language, device, style in
      withEnvironment(
        apiService: mockService,
        colorResolver: AppColorResolver(),
        language: language,
        remoteConfigClient: darkModeOn
      ) {
        let controller = RewardAddOnSelectionViewController.instantiate()
        controller.overrideUserInterfaceStyle = style

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          bonusSupport: nil,
          selectedShippingRule: nil,
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()
        let styleDescription = style == .light ? "light" : "dark"

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)_\(styleDescription)"
        )
      }
    }
  }

  func testView_noAddOns() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    orthogonalCombos(Language.allLanguages, [Device.phone5_8inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        language: language
      ) {
        let controller = RewardAddOnSelectionViewController.instantiate()

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          bonusSupport: nil,
          selectedShippingRule: nil,
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_noReward() {
    let reward = Reward.noReward

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    orthogonalCombos(Language.allLanguages, [Device.phone5_8inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        language: language
      ) {
        let controller = RewardAddOnSelectionViewController.instantiate()

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          bonusSupport: nil,
          selectedShippingRule: nil,
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
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
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.hasAddOns .~ true

    let shippingAddOn1 = Reward.template
      |> Reward.lens.id .~ 2
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn2 = Reward.template
      |> Reward.lens.id .~ 3
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 99)
      ]
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn3 = Reward.template
      |> Reward.lens.id .~ 4
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

    let shippingAddOn4 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [
        shippingRule |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 3)
      ]
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true

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

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        language: language
      ) {
        let controller = RewardAddOnSelectionViewController.instantiate()
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          bonusSupport: nil,
          selectedShippingRule: nil,
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        self.scheduler.advance(by: .seconds(1))

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_Error() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.hasAddOns .~ true
    let project = Project.template

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .failure(.couldNotParseJSON))

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        language: language
      ) {
        let controller = RewardAddOnSelectionViewController.instantiate()

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          bonusSupport: nil,
          selectedShippingRule: nil,
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_NoShippingWithLocalPickup_Success() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.localPickup .~ .australia
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.hasAddOns .~ true

    let noShippingAddOn = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .australia
      |> Reward.lens.isAvailable .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [noShippingAddOn]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    orthogonalCombos(Language.allLanguages, [Device.phone5_8inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        language: language
      ) {
        let controller = RewardAddOnSelectionViewController.instantiate()

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          bonusSupport: nil,
          selectedShippingRule: nil,
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_Addon_Image() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.hasAddOns .~ true

    let noShippingAddOn = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.image .~ Reward.Image(altText: "The image", url: "https://ksr.com/image.jpg")

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [noShippingAddOn]

    let mockService = MockService(fetchRewardAddOnsSelectionViewRewardsResult: .success(project))

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        language: language
      ) {
        let controller = RewardAddOnSelectionViewController.instantiate()

        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          bonusSupport: nil,
          selectedShippingRule: nil,
          selectedQuantities: [:],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 950

        self.scheduler.advance()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
