@testable import KsApi
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import XCTest

final class NoRewardInserterTests: TestCase {
  func testNoRewardFirstInserter_insertsRewardFirst() {
    let inserter = NoRewardFirst()

    let availableReward = Reward.template
      |> Reward.lens.isAvailable .~ true

    let notAvailableReward = Reward.template
      |> Reward.lens.isAvailable .~ false

    let projectRewards = [
      availableReward,
      notAvailableReward
    ]

    let rewards = inserter.insert(noReward: Reward.noReward, intoRewards: projectRewards)
    XCTAssertEqual(rewards.count, 3)
    XCTAssertEqual(
      rewards,
      [
        Reward.noReward,
        availableReward,
        notAvailableReward
      ]
    )
  }

  func testNoRewardFirstInserter_succeedsWithEmptyProjectRewards() {
    let inserter = NoRewardFirst()

    let rewards = inserter.insert(noReward: Reward.noReward, intoRewards: [])
    XCTAssertEqual(rewards.count, 1)
    XCTAssertEqual(rewards, [Reward.noReward])
  }

  func testNoRewardAfterLastAvailableReward_insertsNoRewardBeforeUnavilableRewards_inUnbackedProject() {
    let availableReward = Reward.template
      |> Reward.lens.isAvailable .~ true

    let notAvailableReward = Reward.template
      |> Reward.lens.isAvailable .~ false

    let notStartedYetReward = Reward.template
      |> Reward.lens.startsAt .~ NSDate.distantFuture.timeIntervalSince1970

    let onlyShipsToUSAReward = Reward.shipsToUSAReward
    let onlyShipsToAustraliaReward = Reward.shipsToAustraliaReward
    let digitalReward = Reward.digitalReward
    let localShippingReward = Reward.localShippingReward

    let projectRewards = [
      // Available rewards
      availableReward,
      onlyShipsToUSAReward,
      digitalReward,
      localShippingReward,

      // Unavailable rewards
      notAvailableReward,
      notStartedYetReward,
      onlyShipsToAustraliaReward
    ]

    let inserter = NoRewardAfterLastAvailableReward(
      shippingLocation: Location.usa,
      project: Project.template
    )

    XCTAssertEqual(projectRewards.count, 7)

    let rewards = inserter.insert(noReward: Reward.noReward, intoRewards: projectRewards)

    XCTAssertEqual(rewards.count, 8)
    XCTAssertEqual(rewards, [
      // Available rewards
      availableReward,
      onlyShipsToUSAReward,
      digitalReward,
      localShippingReward,
      Reward.noReward,

      // Unavailable rewards
      notAvailableReward,
      notStartedYetReward,
      onlyShipsToAustraliaReward
    ])
  }

  func testNoRewardAfterLastAvailableReward_insertsNoRewardBeforeUnavilableRewards_withAllUnavailableRewards(
  ) {
    let notAvailableReward = Reward.template
      |> Reward.lens.isAvailable .~ false

    let notStartedYetReward = Reward.template
      |> Reward.lens.startsAt .~ NSDate.distantFuture.timeIntervalSince1970

    let onlyShipsToAustraliaReward = Reward.shipsToAustraliaReward

    let projectRewards = [
      // Unavailable rewards
      notAvailableReward,
      notStartedYetReward,
      onlyShipsToAustraliaReward
    ]

    let inserter = NoRewardAfterLastAvailableReward(
      shippingLocation: Location.usa,
      project: Project.template
    )

    XCTAssertEqual(projectRewards.count, 3)

    let rewards = inserter.insert(noReward: Reward.noReward, intoRewards: projectRewards)

    XCTAssertEqual(rewards.count, 4)
    XCTAssertEqual(rewards, [
      // Available rewards
      Reward.noReward,

      // Unavailable rewards
      notAvailableReward,
      notStartedYetReward,
      onlyShipsToAustraliaReward
    ])
  }

  func testNoRewardAfterLastAvailableReward_allRewardsAvailable_insertsNoRewardAtEndOfList() {
    let availableReward = Reward.template
      |> Reward.lens.isAvailable .~ true

    let onlyShipsToUSAReward = Reward.shipsToUSAReward
    let digitalReward = Reward.digitalReward
    let localShippingReward = Reward.localShippingReward

    let projectRewards = [
      // Available rewards
      availableReward,
      onlyShipsToUSAReward,
      digitalReward,
      localShippingReward
    ]

    let inserter = NoRewardAfterLastAvailableReward(
      shippingLocation: Location.usa,
      project: Project.template
    )

    XCTAssertEqual(projectRewards.count, 4)

    let rewards = inserter.insert(noReward: Reward.noReward, intoRewards: projectRewards)

    XCTAssertEqual(rewards.count, 5)
    XCTAssertEqual(rewards, [
      // Available rewards
      availableReward,
      onlyShipsToUSAReward,
      digitalReward,
      localShippingReward,
      Reward.noReward
    ])
  }

  func testNoRewardAfterLastAvailableReward_succeedsWithEmptyProjectRewards() {
    let inserter = NoRewardAfterLastAvailableReward(
      shippingLocation: nil,
      project: Project.template
    )

    let rewards = inserter.insert(noReward: Reward.noReward, intoRewards: [])
    XCTAssertEqual(rewards, [Reward.noReward])
  }
}
