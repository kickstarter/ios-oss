import Foundation
import GraphAPI
@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import SnapshotTesting
import UIKit
import XCTest

final class RewardsCollectionViewControllerTests: TestCase {
  func testLive_NotBacked() {
    let rewards = Reward.allRewards

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ rewards

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    let mockService = MockService(
      fetchGraphQLResponses: [
        (ShippableLocationsForProjectQuery.self, shippingLocationsData)
      ],
      fetchProjectRewardsResult: .success(rewards)
    )

    withEnvironment(apiService: mockService) {
      forEachScreenshotType { type in
        let vc = RewardsCollectionViewController.instantiate(
          with: project, refTag: nil, context: .createPledge
        )

        vc.pledgeShippingLocationViewController(PledgeShippingLocationViewController(), didSelect: .usa)

        self.scheduler.run()

        let deviceSize = type.device.deviceSize(in: type.orientation)
        let size = CGSize(
          // Make it wide enough to show all cards
          width: CGFloat(rewards.count) * (CheckoutConstants.RewardCard.Layout.width + 40.0) + 100.0,
          height: deviceSize.height
        )

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "rewardsCollectionViewController_testLive_notBacked"
        )
      }
    }
  }

  func testLive_Backed() {
    let user = User.template

    let rewards = Reward.allRewards

    let backing = Backing.template
      |> Backing.lens.backer .~ user
      |> Backing.lens.reward .~ rewards[1]
      |> Backing.lens.rewardId .~ rewards[1].id

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ rewards
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.personalization.isBacking .~ true

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    let mockService = MockService(
      fetchGraphQLResponses: [
        (ShippableLocationsForProjectQuery.self, shippingLocationsData)
      ],
      fetchProjectRewardsResult: .success(rewards)
    )

    withEnvironment(apiService: mockService) {
      forEachScreenshotType { type in
        let vc = RewardsCollectionViewController.instantiate(
          with: project, refTag: nil, context: .managePledge
        )

        vc.pledgeShippingLocationViewController(PledgeShippingLocationViewController(), didSelect: .usa)

        self.scheduler.run()

        let deviceSize = type.device.deviceSize(in: type.orientation)
        let size = CGSize(
          // Make it wide enough to show all cards
          width: CGFloat(rewards.count) * (CheckoutConstants.RewardCard.Layout.width + 40.0) + 100.0,
          height: deviceSize.height
        )

        assertSnapshot(
          forView: vc.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "rewardsCollectionViewController_testLive_backed"
        )
      }
    }
  }
}

private typealias GraphLocation = GraphAPI.ShippableLocationsForProjectQuery.Data.Project
  .ShippableCountriesExpanded

private let shippingLocationsData = GraphAPI.ShippableLocationsForProjectQuery.Data(
  project: GraphAPI.ShippableLocationsForProjectQuery.Data.Project(
    shippableCountriesExpanded: [
      GraphLocation(
        country: "AU",
        countryName: "Australia",
        displayableName: "Australia",
        id: encodeToBase64("Location-8"),
        name: "Australia"
      ),
      GraphLocation(
        country: "CA",
        countryName: "Canada",
        displayableName: "Canada",
        id: encodeToBase64("Location-6"),
        name: "Canada"
      ),
      GraphLocation(
        country: "US",
        countryName: "United States",
        displayableName: "United States",
        id: encodeToBase64("Location-5"),
        name: "United States"
      )
    ]
  )
)

private extension Reward {
  static var allRewards: [Reward] {
    let futureDate = (MockDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0)
    let pastDate = MockDate().date.timeIntervalSince1970 - 1

    let availableAddOnsReward = Reward.template
      |> Reward.lens.title .~ "Available"
      |> Reward.lens.id .~ 1
      |> Reward.lens.hasAddOns .~ true
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.endsAt .~ futureDate
      |> Reward.lens.rewardsItems .~ [
        RewardsItem.template
          |> RewardsItem.lens.quantity .~ 1
          |> RewardsItem.lens.item .~ (
            .template
              |> Item.lens.name .~ "Reward item"
          )
      ]
    let shipsWorldwideReward = Reward.template
      |> Reward.lens.title .~ "Ships worldwide"
      |> Reward.lens.id .~ 2
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 25
      |> Reward.lens.endsAt .~ futureDate
      |> Reward.lens.isAvailable .~ true
      |> Reward.lens.convertedMinimum .~ 7.0
      |> Reward.lens.shipping .~ (
        .template
          |> Reward.Shipping.lens.enabled .~ true
          |> Reward.Shipping.lens.type .~ .anywhere
          |> Reward.Shipping.lens.summary .~ "Ships worldwide"
          |> Reward.Shipping.lens.preference .~ .unrestricted
      )
    let soldOutReward = Reward.template
      |> Reward.lens.title .~ "Sold out"
      |> Reward.lens.id .~ 3
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.convertedMinimum .~ 7.0
      |> Reward.lens.endsAt .~ futureDate

    let endedReward = Reward.postcards
      |> Reward.lens.title .~ "Already ended"
      |> Reward.lens.id .~ 4
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.endsAt .~ pastDate
      |> Reward.lens.convertedMinimum .~ 7.0

    let noReward = Reward.noReward
      |> Reward.lens.convertedMinimum .~ 1

    let usaReward = Reward.shipsToUSAReward
      |> Reward.lens.endsAt .~ futureDate
      |> Reward.lens.id .~ 5

    let australiaReward = Reward.shipsToAustraliaReward
      |> Reward.lens.endsAt .~ futureDate
      |> Reward.lens.id .~ 6

    let localReward = Reward.localShippingReward
      |> Reward.lens.endsAt .~ futureDate
      |> Reward.lens.id .~ 7

    let digitalReward = Reward.digitalReward
      |> Reward.lens.endsAt .~ futureDate
      |> Reward.lens.id .~ 8

    let secretReward = Reward.secretRewardTemplate
      |> Reward.lens.endsAt .~ futureDate
      |> Reward.lens.id .~ 9

    let featuredReward = Reward.featuredReward
      |> Reward.lens.endsAt .~ futureDate
      |> Reward.lens.id .~ 10

    return [
      noReward,
      secretReward,
      featuredReward,
      availableAddOnsReward,
      shipsWorldwideReward,
      usaReward,
      localReward,
      digitalReward,
      australiaReward,
      soldOutReward,
      endedReward
    ]
  }
}
