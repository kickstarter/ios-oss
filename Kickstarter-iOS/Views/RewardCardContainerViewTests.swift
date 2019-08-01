import Foundation
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class RewardCardContainerViewTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  func testLive_BackedProject_BackedReward() {
    combos([Language.en], [Device.phone4_7inch], self.allRewards()).forEach { language, device, rewardTuple in
      withEnvironment(language: language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ true
          |> Project.lens.personalization.backing .~ (
            .template
              |> Backing.lens.reward .~ reward
              |> Backing.lens.rewardId .~ reward.id
              |> Backing.lens.shippingAmount .~ 10
              |> Backing.lens.amount .~ 700
          )

        let vc = rewardCardInViewController(
          language: language,
          device: device,
          project: project,
          reward: reward
        )

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)_\(rewardDescription)")
      }
    }
  }

  func testLive_BackedProject_NonBackedReward() {
    combos([Language.en], [Device.phone4_7inch], self.allRewards()).forEach { language, device, rewardTuple in
      withEnvironment(language: language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ true
          |> Project.lens.personalization.backing .~ (
            .template
              |> Backing.lens.reward .~ Reward.otherReward
              |> Backing.lens.rewardId .~ Reward.otherReward.id
              |> Backing.lens.shippingAmount .~ 10
              |> Backing.lens.amount .~ 700
          )

        let vc = rewardCardInViewController(
          language: language,
          device: device,
          project: project,
          reward: reward
        )

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)_\(rewardDescription)")
      }
    }
  }

  func testLive_NonBackedProject() {
    combos([Language.en], [Device.phone4_7inch], self.allRewards()).forEach { language, device, rewardTuple in
      withEnvironment(language: language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ false

        let vc = rewardCardInViewController(
          language: language,
          device: device,
          project: project,
          reward: reward
        )

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)_\(rewardDescription)")
      }
    }
  }

  func testNonLive_NonBackedProject() {
    combos([Language.en], [Device.phone4_7inch], self.allRewards()).forEach { language, device, rewardTuple in
      withEnvironment(language: language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .successful
          |> Project.lens.personalization.isBacking .~ false

        let vc = rewardCardInViewController(
          language: language,
          device: device,
          project: project,
          reward: reward
        )

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)_\(rewardDescription)")
      }
    }
  }

  func testLive_BackedProject_BackedReward_Errored() {
    // Filter these out because they aren't states we can get to
    let allRewards = self.allRewards()
      .filter { (name, _) -> Bool in
        !name.lowercased().contains("unavailable")
      }

    combos([Language.en], [Device.phone4_7inch], allRewards).forEach { language, device, rewardTuple in
      withEnvironment(language: language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ true
          |> Project.lens.personalization.backing .~ (
            .template
              |> Backing.lens.reward .~ reward
              |> Backing.lens.rewardId .~ reward.id
              |> Backing.lens.shippingAmount .~ 10
              |> Backing.lens.amount .~ 700
              |> Backing.lens.status .~ .errored
          )

        let vc = rewardCardInViewController(
          language: language,
          device: device,
          project: project,
          reward: reward
        )

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)_\(rewardDescription)")
      }
    }
  }

  func testLive_BackedProject_NonBackedReward_Errored() {
    combos([Language.en], [Device.phone4_7inch], self.allRewards()).forEach { language, device, rewardTuple in
      withEnvironment(language: language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ true
          |> Project.lens.personalization.backing .~ (
            .template
              |> Backing.lens.reward .~ Reward.otherReward
              |> Backing.lens.rewardId .~ Reward.otherReward.id
              |> Backing.lens.shippingAmount .~ 10
              |> Backing.lens.amount .~ 700
              |> Backing.lens.status .~ .errored
          )

        let vc = rewardCardInViewController(
          language: language,
          device: device,
          project: project,
          reward: reward
        )

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)_\(rewardDescription)")
      }
    }
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    super.tearDown()
  }

  private func allRewards() -> [(String, Reward)] {
    let availableLimitedReward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 25
    let availableTimebasedReward = Reward.postcards
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ (self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0)
    let availableLimitedTimebasedReward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 25
      |> Reward.lens.endsAt .~ (self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0)
    let availableNonLimitedReward = Reward.postcards
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ nil

    let unavailableLimitedReward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 0
    let unavailableTimebasedReward = Reward.postcards
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ (self.dateType.init().date.timeIntervalSince1970 - 1)
    let unavailableLimitedTimebasedReward = Reward.postcards
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.endsAt .~ (self.dateType.init().date.timeIntervalSince1970 - 1)

    return [
      ("AvailableLimitedReward", availableLimitedReward),
      ("AvailableTimebasedReward", availableTimebasedReward),
      ("AvailableLimitedTimebasedReward", availableLimitedTimebasedReward),
      ("AvailableNonLimitedReward", availableNonLimitedReward),
      ("UnavailableLimitedReward", unavailableLimitedReward),
      ("UnavailableTimebasedReward", unavailableTimebasedReward),
      ("UnavailableLimitedTimebasedReward", unavailableLimitedTimebasedReward),
      ("NoReward", Reward.noReward)
    ]
  }
}

private func rewardCardInViewController(
  language _: Language, device: Device, project: Project, reward: Reward
) -> UIViewController {
  let view = RewardCardContainerView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  view.configure(with: (project: project, reward: .init(left: reward)))

  let controller = UIViewController(nibName: nil, bundle: nil)
  let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
  _ = controller.view
    |> checkoutBackgroundStyle
  controller.view.addSubview(view)
  controller.view.layoutMargins = .init(all: Styles.grid(2))

  NSLayoutConstraint.activate([
    view.leadingAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.leadingAnchor),
    view.topAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.topAnchor),
    view.trailingAnchor.constraint(equalTo: controller.view.layoutMarginsGuide.trailingAnchor),
    view.bottomAnchor.constraint(lessThanOrEqualTo: controller.view.layoutMarginsGuide.bottomAnchor)
  ])

  view.setNeedsLayout()

  return parent
}
