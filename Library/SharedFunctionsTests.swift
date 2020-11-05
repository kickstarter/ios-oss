import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class SharedFunctionsTests: TestCase {
  func testUpdatedUserWithClearedActivityCountProducer_Success() {
    let initialActivitiesCount = 100
    let values = TestObserver<User, Never>()

    let mockApplication = MockApplication()
    mockApplication.applicationIconBadgeNumber = initialActivitiesCount

    let mockService = MockService(
      clearUserUnseenActivityResult: Result.success(.init(activityIndicatorCount: 0))
    )

    let user = User.template
      |> User.lens.unseenActivityCount .~ initialActivitiesCount

    XCTAssertEqual(values.values.map { $0.id }, [])

    withEnvironment(apiService: mockService, application: mockApplication, currentUser: user) {
      _ = updatedUserWithClearedActivityCountProducer()
        .start(on: AppEnvironment.current.scheduler)
        .start(values.observer)

      self.scheduler.advance()

      XCTAssertEqual(values.values.map { $0.id }, [1])
    }
  }

  func testUpdatedUserWithClearedActivityCountProducer_Failure() {
    let initialActivitiesCount = 100
    let values = TestObserver<User, Never>()

    let mockApplication = MockApplication()
    mockApplication.applicationIconBadgeNumber = initialActivitiesCount

    let mockService = MockService(
      clearUserUnseenActivityResult: Result.failure(.invalidInput)
    )

    let user = User.template
      |> User.lens.unseenActivityCount .~ initialActivitiesCount

    XCTAssertEqual(values.values.map { $0.id }, [])

    withEnvironment(apiService: mockService, application: mockApplication, currentUser: user) {
      _ = updatedUserWithClearedActivityCountProducer()
        .start(on: AppEnvironment.current.scheduler)
        .start(values.observer)

      self.scheduler.advance()

      XCTAssertEqual(values.values.map { $0.id }, [])
    }
  }

  func testDefaultShippingRule_Empty() {
    XCTAssertEqual(nil, defaultShippingRule(fromShippingRules: []))
  }

  func testDefaultShippingRule_DoesNotMatchCountryCode_DoesNotMatchUSA() {
    let config = Config.template
      |> Config.lens.countryCode .~ "JP"

    withEnvironment(config: config) {
      let locations = [
        Location.template |> Location.lens.country .~ "DE",
        Location.template |> Location.lens.country .~ "CZ",
        Location.template |> Location.lens.country .~ "CA"
      ]
      let shippingRule = defaultShippingRule(
        fromShippingRules: locations.map { ShippingRule.template |> ShippingRule.lens.location .~ $0 }
      )
      XCTAssertEqual("DE", shippingRule?.location.country)
    }
  }

  func testDefaultShippingRule_DoesNotMatchCountryCode_MatchesUSA() {
    let config = Config.template
      |> Config.lens.countryCode .~ "JP"

    withEnvironment(config: config) {
      let locations = [
        Location.template |> Location.lens.country .~ "US",
        Location.template |> Location.lens.country .~ "CZ",
        Location.template |> Location.lens.country .~ "CA"
      ]
      let shippingRule = defaultShippingRule(
        fromShippingRules: locations.map { ShippingRule.template |> ShippingRule.lens.location .~ $0 }
      )
      XCTAssertEqual("US", shippingRule?.location.country)
    }
  }

  func testDefaultShippingRule_MatchesCountryCode() {
    let config = Config.template
      |> Config.lens.countryCode .~ "CZ"

    withEnvironment(config: config) {
      let locations = [
        Location.template |> Location.lens.country .~ "US",
        Location.template |> Location.lens.country .~ "CZ",
        Location.template |> Location.lens.country .~ "CA"
      ]
      let shippingRule = defaultShippingRule(
        fromShippingRules: locations.map { ShippingRule.template |> ShippingRule.lens.location .~ $0 }
      )
      XCTAssertEqual("CZ", shippingRule?.location.country)
    }
  }

  func testRewardsCarouselCanNavigateToReward_RegularReward_Available_NotBacked_IsCreator() {
    let creator = User.template
      |> User.lens.id .~ 5

    withEnvironment(currentUser: creator) {
      let reward = Reward.template
        |> Reward.lens.limit .~ 5
        |> Reward.lens.remaining .~ 5
        |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)

      let project = Project.template
        |> Project.lens.creator .~ creator
        |> Project.lens.rewardData.rewards .~ [reward]
        |> Project.lens.rewardData.addOns .~ nil

      XCTAssertFalse(rewardsCarouselCanNavigateToReward(reward, in: project))
    }
  }

  func testRewardsCarouselCanNavigateToReward_RegularReward_Available_NotBacked() {
    let reward = Reward.template
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 5
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ nil

    XCTAssertTrue(rewardsCarouselCanNavigateToReward(reward, in: project))
  }

  func testRewardsCarouselCanNavigateToReward_RegularReward_Available_Backed() {
    let reward = Reward.template
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 5
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)

    let project = Project.cosmicSurgery
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
      )

    XCTAssertFalse(rewardsCarouselCanNavigateToReward(reward, in: project))
  }

  func testRewardsCarouselCanNavigateToReward_RegularReward_Unavailable_Backed() {
    let reward = Reward.template
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)

    let project = Project.cosmicSurgery
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
      )

    XCTAssertFalse(rewardsCarouselCanNavigateToReward(reward, in: project))
  }

  func testRewardsCarouselCanNavigateToReward_RegularReward_Expired_Backed() {
    let reward = Reward.template
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 2
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 - 1)

    let project = Project.cosmicSurgery
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
      )

    XCTAssertFalse(rewardsCarouselCanNavigateToReward(reward, in: project))
  }

  func testRewardsCarouselCanNavigateToReward_RegularReward_Unavailable_NotBacked() {
    let reward = Reward.template
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ nil

    XCTAssertFalse(rewardsCarouselCanNavigateToReward(reward, in: project))
  }

  func testRewardsCarouselCanNavigateToReward_RegularReward_Expired_NotBacked() {
    let reward = Reward.template
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 2
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 - 1)

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ nil

    XCTAssertFalse(rewardsCarouselCanNavigateToReward(reward, in: project))
  }

  func testRewardsCarouselCanNavigateToReward_Reward_Available_NotBacked_HasAddOns() {
    let reward = Reward.template
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 5
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)
      |> Reward.lens.hasAddOns .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [reward]

    XCTAssertTrue(rewardsCarouselCanNavigateToReward(reward, in: project))
  }

  func testRewardsCarouselCanNavigateToReward_Reward_Unavailable_NotBacked_HasAddOns() {
    let reward = Reward.template
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)
      |> Reward.lens.hasAddOns .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [reward]

    XCTAssertFalse(rewardsCarouselCanNavigateToReward(reward, in: project))
  }

  func testRewardsCarouselCanNavigateToReward_Reward_Expired_NotBacked_HasAddOns() {
    let reward = Reward.template
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 2
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 - 1)
      |> Reward.lens.hasAddOns .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [reward]

    XCTAssertFalse(rewardsCarouselCanNavigateToReward(reward, in: project))
  }

  func testRewardsCarouselCanNavigateToReward_Reward_Unavailable_Backed_HasAddOns() {
    let reward = Reward.template
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)
      |> Reward.lens.hasAddOns .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
      )

    XCTAssertTrue(rewardsCarouselCanNavigateToReward(reward, in: project))
  }

  func testRewardsCarouselCanNavigateToReward_Reward_Expired_Backed_HasAddOns() {
    let reward = Reward.template
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 2
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 - 1)
      |> Reward.lens.hasAddOns .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
      )

    XCTAssertTrue(rewardsCarouselCanNavigateToReward(reward, in: project))
  }

  func testIsStartDateBeforeToday_Reward_StartsAt_Nil() {
    let reward = Reward.template
      |> Reward.lens.startsAt .~ nil

    XCTAssertTrue(isStartDateBeforeToday(for: reward))
  }

  func testIsStartDateBeforeToday_Reward_StartsAt_PastDate() {
    let reward = Reward.template
      |> Reward.lens.startsAt .~ (MockDate().timeIntervalSince1970 - 60)

    XCTAssertTrue(isStartDateBeforeToday(for: reward))
  }

  func testIsStartDateBeforeToday_Reward_StartsAt_FutureDate() {
    let reward = Reward.template
      |> Reward.lens.startsAt .~ (MockDate().timeIntervalSince1970 + 60)

    XCTAssertFalse(isStartDateBeforeToday(for: reward))
  }

  func testIsEndDateAfterToday_Reward_EndsAt_Nil() {
    let reward = Reward.template
      |> Reward.lens.endsAt .~ nil

    XCTAssertTrue(isEndDateAfterToday(for: reward))
  }

  func testIsEndDateAfterToday_Reward_EndsAt_PastDate() {
    let reward = Reward.template
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 - 60)

    XCTAssertFalse(isEndDateAfterToday(for: reward))
  }

  func testIsEndDateAfterToday_Reward_EndsAt_FutureDate() {
    let reward = Reward.template
      |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60)

    XCTAssertTrue(isEndDateAfterToday(for: reward))
  }
}
