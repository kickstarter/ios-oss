import Foundation
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit
import XCTest

final class RewardCardContainerViewTests: TestCase {
  func testLive_BackedProject_BackedReward() {
    forEachScreenshotType(withData: allRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(language: type.language) {
        let (rewardDescription, reward) = rewardTuple

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

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testLive_BackedProject_BackedReward_\(rewardDescription)"
        )
      }
    }
  }

  func testLive_BackedProject_RewardImage() {
    forEachScreenshotType(languages: [.en]) { type in
      withSnapshotEnvironment(language: type.language) {
        let reward = Reward.postcards
          |> Reward.lens.isAvailable .~ true
          |> Reward.lens.image .~ Reward.Image(altText: "The image", url: "https://ksr.com/image.jpg")

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

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = CGSize(
          width: type.device.deviceSize(in: type.orientation).width,
          height: 900
        )

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testLive_BackedProject_RewardImage"
        )
      }
    }
  }

  func testLive_BackedProject_BackedReward_LoggedIn() {
    let user = User.template

    forEachScreenshotType(withData: allRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(currentUser: user, language: type.language) {
        let (rewardDescription, reward) = rewardTuple

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

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testLive_BackedProject_BackedReward_LoggedIn_\(rewardDescription)"
        )
      }
    }
  }

  func testLive_BackedProject_NonBackedReward() {
    forEachScreenshotType(withData: allRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(language: type.language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ true
          |> Project.lens.personalization.backing .~ (
            .template
              |> Backing.lens.reward .~ Reward.otherReward
              |> Backing.lens.rewardId .~ Reward.otherReward.id
              |> Backing.lens.shippingAmount .~ 10
              |> Backing.lens.amount .~ 700.0
          )

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testLive_BackedProject_NonBackedReward_\(rewardDescription)"
        )
      }
    }
  }

  func testLive_NonBackedProject_LoggedIn() {
    let nonCreator = User.template
      |> User.lens.id .~ 5

    forEachScreenshotType(withData: allRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(currentUser: nonCreator, language: type.language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ false
          |> Project.lens.personalization.backing .~ nil

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testLive_NonBackedProject_LoggedIn_\(rewardDescription)"
        )
      }
    }
  }

  func testLive_NonBackedProject_LoggedOut() {
    forEachScreenshotType(withData: allRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(currentUser: nil, language: type.language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ nil
          |> Project.lens.personalization.backing .~ nil

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testLive_NonBackedProject_LoggedOut_\(rewardDescription)"
        )
      }
    }
  }

  func testNonLive_BackedProject_BackedReward() {
    forEachScreenshotType(withData: allRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(language: type.language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .successful
          |> Project.lens.personalization.isBacking .~ true
          |> Project.lens.personalization.backing .~ (
            .template
              |> Backing.lens.reward .~ reward
              |> Backing.lens.rewardId .~ reward.id
              |> Backing.lens.shippingAmount .~ 10
              |> Backing.lens.amount .~ 700.0
          )

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testNonLive_BackedProject_BackedReward_\(rewardDescription)"
        )
      }
    }
  }

  func testNonLive_BackedProject_NonBackedReward() {
    forEachScreenshotType(withData: allRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(language: type.language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .successful
          |> Project.lens.personalization.isBacking .~ true
          |> Project.lens.personalization.backing .~ (
            .template
              |> Backing.lens.reward .~ Reward.otherReward
              |> Backing.lens.rewardId .~ Reward.otherReward.id
              |> Backing.lens.shippingAmount .~ 10
              |> Backing.lens.amount .~ 700.0
          )

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testNonLive_BackedProject_NonBackedReward_\(rewardDescription)"
        )
      }
    }
  }

  func testNonLive_NonBackedProject() {
    forEachScreenshotType(withData: allRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(language: type.language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .successful
          |> Project.lens.personalization.isBacking .~ false

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testNonLive_NonBackedProject_\(rewardDescription)"
        )
      }
    }
  }

  func testLive_BackedProject_BackedReward_Errored() {
    // Filter these out because they aren't states we can get to
    let filteredRewards = allRewards
      .filter { name, _ -> Bool in
        !name.lowercased().contains("unavailable")
      }

    forEachScreenshotType(withData: filteredRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(language: type.language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ true
          |> Project.lens.personalization.backing .~ (
            .template
              |> Backing.lens.reward .~ reward
              |> Backing.lens.rewardId .~ reward.id
              |> Backing.lens.shippingAmount .~ 10
              |> Backing.lens.amount .~ 700.0
              |> Backing.lens.status .~ .errored
          )

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testLive_BackedProject_BackedReward_Errored_\(rewardDescription)"
        )
      }
    }
  }

  func testNonLive_BackedProject_BackedReward_Errored() {
    // Filter these out because they aren't states we can get to
    let filteredRewards = allRewards
      .filter { name, _ -> Bool in
        !name.lowercased().contains("unavailable")
      }

    forEachScreenshotType(withData: filteredRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(language: type.language) {
        let (rewardDescription, reward) = rewardTuple

        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .successful
          |> Project.lens.personalization.isBacking .~ true
          |> Project.lens.personalization.backing .~ (
            .template
              |> Backing.lens.reward .~ reward
              |> Backing.lens.rewardId .~ reward.id
              |> Backing.lens.shippingAmount .~ 10
              |> Backing.lens.amount .~ 700.0
              |> Backing.lens.status .~ .errored
          )

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testNonLive_BackedProject_BackedReward_Errored_\(rewardDescription)"
        )
      }
    }
  }

  func testLive_IsCreator() {
    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ user
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil

    forEachScreenshotType(withData: allRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(currentUser: user, language: type.language) {
        let (rewardDescription, reward) = rewardTuple

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testLive_IsCreator_\(rewardDescription)"
        )
      }
    }
  }

  func testNonLive_IsCreator() {
    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ user
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil

    forEachScreenshotType(withData: allRewards, languages: [.en]) { type, rewardTuple in
      withSnapshotEnvironment(currentUser: user, language: type.language) {
        let (rewardDescription, reward) = rewardTuple

        let vc = rewardCardInViewController(
          project: project,
          reward: reward
        )

        let size = type.device.deviceSize(in: type.orientation)

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testNonLive_IsCreator_\(rewardDescription)"
        )
      }
    }
  }
}

private func rewardCardInViewController(
  project: Project, reward: Reward
) -> UIViewController {
  let view = RewardCardContainerView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false

  let controller = UIViewController(nibName: nil, bundle: nil)
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

  let safeProject = stripImageURLs(project)

  view.configure(with: RewardCardViewData(
    project: safeProject,
    reward: reward,
    context: .pledge,
    currentShippingLocation: nil
  ))

  return controller
}

private func stripImageURLs(_ project: Project) -> Project {
  project
    |> Project.lens.photo.full .~ ""
    |> Project.lens.photo.med .~ ""
    |> Project.lens.photo.small .~ ""
}

private extension RewardCardContainerViewTests {
  func withSnapshotEnvironment(
    currentUser: User? = nil,
    language: Language,
    body: () -> Void
  ) {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    self.withEnvironment(
      calendar: calendar,
      currentUser: currentUser,
      language: language,
      locale: Locale(identifier: language.rawValue),
      mainBundle: Bundle(for: RewardCardContainerViewTests.self),
      body: body
    )
  }
}

let allRewards: [(String, Reward)] = {
  let availableAddOnsReward = Reward.postcards
    |> Reward.lens.hasAddOns .~ true
    |> Reward.lens.limit .~ nil
    |> Reward.lens.remaining .~ nil
    |> Reward.lens.isAvailable .~ true
  let availableLimitedReward = Reward.postcards
    |> Reward.lens.limit .~ 100
    |> Reward.lens.remaining .~ 25
    |> Reward.lens.convertedMinimum .~ 7.0
    |> Reward.lens.isAvailable .~ true
  let availableTimebasedReward = Reward.postcards
    |> Reward.lens.limit .~ nil
    |> Reward.lens.remaining .~ nil
    |> Reward.lens.convertedMinimum .~ 7.0
    |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0)
    |> Reward.lens.isAvailable .~ true
  let availableLimitedTimebasedReward = Reward.postcards
    |> Reward.lens.limit .~ 100
    |> Reward.lens.remaining .~ 25
    |> Reward.lens.convertedMinimum .~ 7.0
    |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0)
    |> Reward.lens.isAvailable .~ true
  let availableNonLimitedReward = Reward.postcards
    |> Reward.lens.limit .~ nil
    |> Reward.lens.remaining .~ nil
    |> Reward.lens.endsAt .~ nil
    |> Reward.lens.convertedMinimum .~ 7.0
    |> Reward.lens.isAvailable .~ true
  let availableShippingEnabledReward = Reward.postcards
    |> Reward.lens.limit .~ 100
    |> Reward.lens.remaining .~ 25
    |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0)
    |> Reward.lens.isAvailable .~ true
    |> Reward.lens.convertedMinimum .~ 7.0
    |> Reward.lens.shipping .~ (
      .template
        |> Reward.Shipping.lens.enabled .~ true
        |> Reward.Shipping.lens.type .~ .anywhere
        |> Reward.Shipping.lens.summary .~ "Ships worldwide"
    )
  let unavailableLimitedReward = Reward.postcards
    |> Reward.lens.limit .~ 100
    |> Reward.lens.remaining .~ 0
    |> Reward.lens.convertedMinimum .~ 7.0
  let unavailableTimebasedReward = Reward.postcards
    |> Reward.lens.limit .~ nil
    |> Reward.lens.remaining .~ nil
    |> Reward.lens.endsAt .~ (MockDate().date.timeIntervalSince1970 - 1)
    |> Reward.lens.convertedMinimum .~ 7.0
  let unavailableLimitedTimebasedReward = Reward.postcards
    |> Reward.lens.limit .~ 100
    |> Reward.lens.remaining .~ 0
    |> Reward.lens.convertedMinimum .~ 7.0
    |> Reward.lens.endsAt .~ (MockDate().date.timeIntervalSince1970 - 1)
  let unavailableShippingEnabledReward = Reward.postcards
    |> Reward.lens.limit .~ 100
    |> Reward.lens.remaining .~ 0
    |> Reward.lens.convertedMinimum .~ 7.0

    |> Reward.lens.endsAt .~ (MockDate().date.timeIntervalSince1970 - 1)
    |> Reward.lens.shipping .~ (
      .template
        |> Reward.Shipping.lens.enabled .~ true
        |> Reward.Shipping.lens.type .~ .anywhere
        |> Reward.Shipping.lens.summary .~ "Ships worldwide"
    )
  let noReward = Reward.noReward
    |> Reward.lens.convertedMinimum .~ 1

  return [
    ("AvailableAddOnsReward", availableAddOnsReward),
    ("AvailableLimitedReward", availableLimitedReward),
    ("AvailableTimebasedReward", availableTimebasedReward),
    ("AvailableLimitedTimebasedReward", availableLimitedTimebasedReward),
    ("AvailableNonLimitedReward", availableNonLimitedReward),
    ("AvailableShippingEnabledReward", availableShippingEnabledReward),
    ("UnavailableLimitedReward", unavailableLimitedReward),
    ("UnavailableTimebasedReward", unavailableTimebasedReward),
    ("UnavailableLimitedTimebasedReward", unavailableLimitedTimebasedReward),
    ("UnavailableShippingEnabledReward", unavailableShippingEnabledReward),
    ("NoReward", noReward)
  ]
}()
