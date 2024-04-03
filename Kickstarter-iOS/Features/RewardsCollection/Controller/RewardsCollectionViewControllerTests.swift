@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
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

    let language = Language.en, device = Device.phone4_7inch
    withEnvironment(language: language, locale: .init(identifier: language.rawValue)) {
      let vc = RewardsCollectionViewController.instantiate(
        with: project,
        refTag: nil,
        context: .createPledge
      )
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

      assertSnapshot(
        matching: parent.view,
        as: .image(perceptualPrecision: 0.98),
        named: "lang_\(language)_device_\(device)"
      )
    }
  }

  func testRewards_NonBacker_LiveProject_Landscape() {
    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards %~ { Array($0[1...3]) }

    let language = Language.de, device = Device.pad
    withEnvironment(language: language, locale: .init(identifier: language.rawValue)) {
      let vc = RewardsCollectionViewController.instantiate(
        with: project,
        refTag: nil,
        context: .createPledge
      )
      let (parent, _) = traitControllers(device: device, orientation: .landscape, child: vc)

      assertSnapshot(
        matching: parent.view,
        as: .image(perceptualPrecision: 0.98),
        named: "lang_\(language)_device_\(device)"
      )
    }
  }

  func testRewards_Backer_LiveProject_Landscape() {
    let reward = Project.cosmicSurgery.rewards[3]
    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
          |> Backing.lens.addOns .~ []
      )

    let language = Language.es, device = Device.phone5_8inch
    withEnvironment(language: language, locale: .init(identifier: language.rawValue)) {
      let vc = RewardsCollectionViewController.instantiate(
        with: project,
        refTag: nil,
        context: .createPledge
      )
      let (parent, _) = traitControllers(device: device, orientation: .landscape, child: vc)

      assertSnapshot(
        matching: parent.view,
        as: .image(perceptualPrecision: 0.98),
        named: "lang_\(language)_device_\(device)"
      )
    }
  }

  func testRewards_LocalPickUp_LiveProject_Landscape() {
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .canada
      |> Reward.lens.isAvailable .~ true

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ [reward]

    let language = Language.fr, device = Device.pad
    withEnvironment(
      language: language,
      locale: .init(identifier: language.rawValue)
    ) {
      let vc = RewardsCollectionViewController.instantiate(
        with: project,
        refTag: nil,
        context: .createPledge
      )
      let (parent, _) = traitControllers(device: device, orientation: .landscape, child: vc)

      assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
    }
  }

  func testRewards_LocalPickUp_LiveProject_Portrait() {
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .canada

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ [reward]

    let language = Language.ja, device = Device.phone5_8inch
    withEnvironment(
      language: language,
      locale: .init(identifier: language.rawValue)
    ) {
      let vc = RewardsCollectionViewController.instantiate(
        with: project,
        refTag: nil,
        context: .createPledge
      )
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

      assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
    }
  }

  func testRewards_LocalPickUp_RewardNotBacked_AllRewardsShown_Success() {
    let reward = Reward.template
      |> Reward.lens.shipping.preference .~ .local
      |> Reward.lens.localPickup .~ .canada

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.rewardData.rewards .~ [.noReward, reward]

    let language = Language.en, device = Device.phone5_8inch
    withEnvironment(
      language: language,
      locale: .init(identifier: language.rawValue)
    ) {
      let vc = RewardsCollectionViewController.instantiate(
        with: project,
        refTag: nil,
        context: .createPledge
      )
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

      assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
    }
  }

  func testRewards_LocalPickUp_RewardBacked_LocalPickupRewardShown_Success() {
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

    let language = Language.de, device = Device.phone5_8inch
    withEnvironment(
      language: language,
      locale: .init(identifier: language.rawValue)
    ) {
      let vc = RewardsCollectionViewController.instantiate(
        with: project,
        refTag: nil,
        context: .createPledge
      )
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

      assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
    }
  }
}
