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
    let rewards = Reward.allRewards.map { $1 }

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ rewards

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    let mockService = MockService(fetchGraphQLResponses: [
      (ShippableLocationsForProjectQuery.self, shippingLocationsData)
    ])

    withEnvironment(apiService: mockService) {
      forEachScreenshotType { type in
        let vc = RewardsCollectionViewController.instantiate(
          with: project, refTag: nil, context: .createPledge
        )

        vc.pledgeShippingLocationViewController(PledgeShippingLocationViewController(), didSelect: .usa)

        self.scheduler.run()

        let deviceSize = type.device.deviceSize(in: type.orientation)
        let size = CGSizeMake(
          // Make it wide enough to show all cards
          CGFloat(rewards.count) * (CheckoutConstants.RewardCard.Layout.width + 40.0) + 100.0,
          deviceSize.height
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

    let rewards = Reward.allRewards.map { $1 }

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

    let mockService = MockService(fetchGraphQLResponses: [
      (ShippableLocationsForProjectQuery.self, shippingLocationsData)
    ])

    withEnvironment(apiService: mockService) {
      forEachScreenshotType { type in
        let vc = RewardsCollectionViewController.instantiate(
          with: project, refTag: nil, context: .managePledge
        )

        vc.pledgeShippingLocationViewController(PledgeShippingLocationViewController(), didSelect: .usa)

        self.scheduler.run()

        let deviceSize = type.device.deviceSize(in: type.orientation)
        let size = CGSizeMake(
          // Make it wide enough to show all cards
          CGFloat(rewards.count) * (CheckoutConstants.RewardCard.Layout.width + 40.0) + 100.0,
          deviceSize.height
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
