@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class RewardsCollectionViewControllerTests: TestCase {
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

  func testRewards_NonBacker_LiveProject() {
    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language, locale: .init(identifier: language.rawValue)) {
        let vc = RewardsCollectionViewController.instantiate(
          with: project,
          refTag: nil,
          context: .createPledge
        )
        _ = traitControllers(device: device, orientation: .portrait, child: vc)

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testRewards_NonBacker_LiveProject_Landscape() {
    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language, locale: .init(identifier: language.rawValue)) {
        let vc = RewardsCollectionViewController.instantiate(
          with: project,
          refTag: nil,
          context: .createPledge
        )
        _ = traitControllers(device: device, orientation: .landscape, child: vc)

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testRewards_Backer_LiveProject_Landscape() {
    let reward = Project.cosmicSurgery.rewards[1]
    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language, locale: .init(identifier: language.rawValue)) {
        let vc = RewardsCollectionViewController.instantiate(
          with: project,
          refTag: nil,
          context: .createPledge
        )
        _ = traitControllers(device: device, orientation: .landscape, child: vc)

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testRewards_LocalPickUp_LiveProject_Landscape() {
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .canada

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ [reward]

    let optimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.rewardLocalPickupEnabled.rawValue:
          true
      ]

    combos(Language.allLanguages, [Device.pad]).forEach {
      language, device in
      withEnvironment(
        language: language,
        locale: .init(identifier: language.rawValue),
        optimizelyClient: optimizelyClient
      ) {
        let vc = RewardsCollectionViewController.instantiate(
          with: project,
          refTag: nil,
          context: .createPledge
        )
        _ = traitControllers(device: device, orientation: .landscape, child: vc)

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testRewards_LocalPickUp_LiveProject_Portrait() {
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .canada

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ [reward]

    let optimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.rewardLocalPickupEnabled.rawValue:
          true
      ]

    combos(Language.allLanguages, [Device.phone5_8inch]).forEach {
      language, device in
      withEnvironment(
        language: language,
        locale: .init(identifier: language.rawValue),
        optimizelyClient: optimizelyClient
      ) {
        let vc = RewardsCollectionViewController.instantiate(
          with: project,
          refTag: nil,
          context: .createPledge
        )
        _ = traitControllers(device: device, orientation: .portrait, child: vc)

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testRewards_LocalPickUp_FeatureDisabled_RewardNotBacked_NoLocalPickupRewardShown_Success() {
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .canada

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ [.noReward, reward]

    let optimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.rewardLocalPickupEnabled.rawValue:
          false
      ]

    combos(Language.allLanguages, [Device.phone5_8inch]).forEach {
      language, device in
      withEnvironment(
        language: language,
        locale: .init(identifier: language.rawValue),
        optimizelyClient: optimizelyClient
      ) {
        let vc = RewardsCollectionViewController.instantiate(
          with: project,
          refTag: nil,
          context: .createPledge
        )
        _ = traitControllers(device: device, orientation: .portrait, child: vc)

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testRewards_LocalPickUp_FeatureDisabled_RewardBacked_LocalPickupRewardShown_Success() {
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .canada

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
      )
      |> Project.lens.rewardData.rewards .~ [reward]

    let optimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.rewardLocalPickupEnabled.rawValue:
          false
      ]

    combos(Language.allLanguages, [Device.phone5_8inch]).forEach {
      language, device in
      withEnvironment(
        language: language,
        locale: .init(identifier: language.rawValue),
        optimizelyClient: optimizelyClient
      ) {
        let vc = RewardsCollectionViewController.instantiate(
          with: project,
          refTag: nil,
          context: .createPledge
        )
        _ = traitControllers(device: device, orientation: .portrait, child: vc)

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testRewards_LocalPickUp_FeatureEnabled_RewardNotBacked_LocalPickupRewardShown_Success() {
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .canada

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ [reward]

    let optimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.rewardLocalPickupEnabled.rawValue:
          true
      ]

    combos(Language.allLanguages, [Device.phone5_8inch]).forEach {
      language, device in
      withEnvironment(
        language: language,
        locale: .init(identifier: language.rawValue),
        optimizelyClient: optimizelyClient
      ) {
        let vc = RewardsCollectionViewController.instantiate(
          with: project,
          refTag: nil,
          context: .createPledge
        )
        _ = traitControllers(device: device, orientation: .portrait, child: vc)

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
