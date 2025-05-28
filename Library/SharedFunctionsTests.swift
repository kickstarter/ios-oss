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
      clearUserUnseenActivityResult: Result.failure(.couldNotParseJSON)
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
      |> Reward.lens.isAvailable .~ true

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

    withEnvironment {
      XCTAssertTrue(rewardsCarouselCanNavigateToReward(reward, in: project))
    }
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

    XCTAssertTrue(rewardsCarouselCanNavigateToReward(reward, in: project))
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

    XCTAssertTrue(rewardsCarouselCanNavigateToReward(reward, in: project))
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
      |> Reward.lens.isAvailable .~ true

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

  func testRoundedToDecimalPlaces_Double() {
    let amount: Double = 30.5657676754

    let roundedTo2dp = rounded(amount, places: 2)
    let roundedTo4dp = rounded(amount, places: 4)

    XCTAssertEqual(30.57, roundedTo2dp)
    XCTAssertEqual(30.5658, roundedTo4dp)
  }

  func testRoundedToDecimalPlaces_Float() {
    let amount: Float = 30.5657676754

    let roundedTo2dp = rounded(amount, places: 2)
    let roundedTo4dp = rounded(amount, places: 4)

    XCTAssertEqual(30.57, roundedTo2dp)
    XCTAssertEqual(30.5658, roundedTo4dp)
  }

  func testCheckoutProperties() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let rewards = [reward, Reward.template]
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ rewards

    let selectedQuantities = [reward.id: 1]
    let baseReward = project.rewards.first!

    let checkoutPropertiesData = checkoutProperties(
      from: project,
      baseReward: baseReward,
      addOnRewards: [reward],
      selectedQuantities: selectedQuantities,
      additionalPledgeAmount: 10.0,
      pledgeTotal: 100.0,
      shippingTotal: 10.0,
      checkoutId: nil,
      isApplePay: false
    )

    XCTAssertEqual(0, checkoutPropertiesData.addOnsCountTotal)
    XCTAssertEqual(0, checkoutPropertiesData.addOnsCountUnique)
    XCTAssertEqual(0.00, checkoutPropertiesData.addOnsMinimumUsd)
    XCTAssertEqual(10.00, checkoutPropertiesData.bonusAmountInUsd)
    XCTAssertEqual(nil, checkoutPropertiesData.checkoutId)
    XCTAssertEqual(
      1_506_897_315.0,
      checkoutPropertiesData.estimatedDelivery
    )
    XCTAssertEqual("credit_card", checkoutPropertiesData.paymentType)
    XCTAssertEqual(100.0, checkoutPropertiesData.revenueInUsd)
    XCTAssertEqual("1", checkoutPropertiesData.rewardId)
    XCTAssertEqual(10.00, checkoutPropertiesData.rewardMinimumUsd)
    XCTAssertEqual("My Reward", checkoutPropertiesData.rewardTitle)
    XCTAssertEqual(true, checkoutPropertiesData.shippingEnabled)
    XCTAssertEqual(10.00, checkoutPropertiesData.shippingAmountUsd)
    XCTAssertEqual(
      true,
      checkoutPropertiesData.userHasStoredApplePayCard
    )
  }

  func testGetShipping_ShippingEnabled_Backing() {
    let reward = Reward.template
      |> Reward.lens.hasAddOns .~ true
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
      )

    let shippingTotal = getBaseRewardShippingTotal(
      project: project,
      baseReward: reward,
      shippingRule: ShippingRule.template
    )

    XCTAssertEqual(2.0, shippingTotal)
  }

  func testGetShipping_ShippingEnabled_NotBacking() {
    let reward = Reward.template
      |> Reward.lens.hasAddOns .~ true
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [reward]

    let shippingTotal = getBaseRewardShippingTotal(
      project: project,
      baseReward: reward,
      shippingRule: ShippingRule.template
    )

    XCTAssertEqual(5.0, shippingTotal)
  }

  func testGetShipping_ShippingDisabled() {
    let reward = Reward.template
      |> Reward.lens.hasAddOns .~ true
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.rewardData.addOns .~ [reward]

    let shippingTotal = getBaseRewardShippingTotal(
      project: project,
      baseReward: reward,
      shippingRule: ShippingRule.template
    )

    XCTAssertEqual(0.0, shippingTotal)
  }

  func testGetCalculated_ShippingEnabled_Total() {
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)
      |> Reward.lens.id .~ 99
    let addOn1 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 10
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    let quantities: SelectedRewardQuantities = [
      reward.id: 1,
      addOn1.id: 2,
      addOn2.id: 1
    ]

    let shippingTotal = calculateShippingTotal(
      shippingRule: ShippingRule.template,
      addOnRewards: [addOn1, addOn2],
      quantities: quantities
    )

    XCTAssertEqual(15.0, shippingTotal)
  }

  func testGetCalculated_ShippingDisabled_Total() {
    let shipping = Reward.Shipping.template
      |> Reward.Shipping.lens.enabled .~ false
      |> Reward.Shipping.lens.preference .~ Reward.Shipping.Preference.none

    let reward = Reward.template
      |> Reward.lens.shipping .~ shipping
      |> Reward.lens.id .~ 99
    let addOn1 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 10
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.shipping.preference .~ Reward.Shipping.Preference.none

    let quantities: SelectedRewardQuantities = [
      reward.id: 1,
      addOn1.id: 2,
      addOn2.id: 1
    ]

    let shippingTotal = calculateShippingTotal(
      shippingRule: ShippingRule.template,
      addOnRewards: [addOn1, addOn2],
      quantities: quantities
    )

    XCTAssertEqual(0.0, shippingTotal)
  }

  func testCalculated_Pledge_Total_Backing() {
    let reward = Reward.template
      |> Reward.lens.hasAddOns .~ true
      |> Reward.lens.shipping.enabled .~ true
    let addOn1 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 10
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    let project = Project.template
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
          |> Backing.lens.bonusAmount .~ 700.0
      )

    let quantities: SelectedRewardQuantities = [
      reward.id: 1,
      addOn1.id: 2,
      addOn2.id: 1
    ]

    let addOnRewards = [addOn1, addOn2]

    let pledgeAmount = project.personalization.backing?.bonusAmount ?? 0.0

    let shippingTotal = calculateShippingTotal(
      shippingRule: ShippingRule.template,
      addOnRewards: addOnRewards,
      quantities: quantities
    )

    let allRewardsTotal = calculateAllRewardsTotal(
      addOnRewards: addOnRewards,
      selectedQuantities: quantities
    )

    let pledgeTotal = calculatePledgeTotal(
      pledgeAmount: pledgeAmount,
      shippingCost: shippingTotal,
      addOnRewardsTotal: allRewardsTotal
    )

    XCTAssertEqual(745.0, pledgeTotal)
  }

  func testCalculated_Pledge_Total_NotBacking() {
    let reward = Reward.template
      |> Reward.lens.hasAddOns .~ true
      |> Reward.lens.shipping.enabled .~ true
    let addOn1 = Reward.template
      |> Reward.lens.id .~ 5
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 10
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)

    let quantities: SelectedRewardQuantities = [
      reward.id: 1,
      addOn1.id: 2,
      addOn2.id: 1
    ]

    let addOnRewards = [addOn1, addOn2]

    let shippingTotal = calculateShippingTotal(
      shippingRule: ShippingRule.template,
      addOnRewards: addOnRewards,
      quantities: quantities
    )

    let allRewardsTotal = calculateAllRewardsTotal(
      addOnRewards: addOnRewards,
      selectedQuantities: quantities
    )

    let pledgeTotal = calculatePledgeTotal(
      pledgeAmount: 10,
      shippingCost: shippingTotal,
      addOnRewardsTotal: allRewardsTotal
    )

    XCTAssertEqual(55.0, pledgeTotal)
  }

  func testGetCalculated_AllRewards_Total() {
    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)
      |> Reward.lens.id .~ 99
    let addOn1 = Reward.template
      |> Reward.lens.id .~ 5
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 10

    let quantities: SelectedRewardQuantities = [
      reward.id: 1,
      addOn1.id: 2,
      addOn2.id: 1
    ]

    let rewardsTotal = calculateAllRewardsTotal(
      addOnRewards: [addOn1, addOn2],
      selectedQuantities: quantities
    )

    XCTAssertEqual(30.0, rewardsTotal)
  }

  func test_IsRewardLocalPickup_Success() {
    let baseReward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.preference .~ .unrestricted)
      |> Reward.lens.localPickup .~ .losAngeles

    XCTAssertFalse(isRewardLocalPickup(baseReward))

    let reward = baseReward
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.preference .~ .local)

    XCTAssertTrue(isRewardLocalPickup(reward))
  }

  func test_IsRewardDigital_Success() {
    let baseReward = Reward.template
      |> Reward.lens
      .shipping .~ (.template |> Reward.Shipping.lens.preference .~ Reward.Shipping.Preference.unrestricted)

    XCTAssertFalse(isRewardDigital(baseReward))

    let reward = Reward.template
      |> Reward.lens
      .shipping .~ (.template |> Reward.Shipping.lens.preference .~ Reward.Shipping.Preference.none)

    XCTAssertTrue(isRewardDigital(reward))
  }

  func test_estimatedShippingText() {
    let rewardShippingRule = ShippingRule.template
      |> ShippingRule.lens.estimatedMin .~ Money(amount: 2)
      |> ShippingRule.lens.estimatedMax .~ Money(amount: 7)
    let addOnShippingRule = ShippingRule.template
      |> ShippingRule.lens.estimatedMin .~ Money(amount: 1)
      |> ShippingRule.lens.estimatedMax .~ Money(amount: 5)

    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)
      |> Reward.lens.shippingRulesExpanded .~ [rewardShippingRule]
      |> Reward.lens.id .~ 99
    let addOn = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)
      |> Reward.lens.id .~ 5
      |> Reward.lens.shippingRulesExpanded .~ [addOnShippingRule]

    let project = Project.template

    let estimatedShipping = estimatedShippingText(
      for: [reward, addOn],
      project: project,
      locationId: ShippingRule.template.location.id
    )

    XCTAssertEqual(estimatedShipping, "$3-$12")
  }

  func test_estimatedShippingText_IncludesSelectedQuantities() {
    let rewardShippingRule = ShippingRule.template
      |> ShippingRule.lens.estimatedMin .~ Money(amount: 1)
      |> ShippingRule.lens.estimatedMax .~ Money(amount: 10)
    let addOnShippingRule = ShippingRule.template
      |> ShippingRule.lens.estimatedMin .~ Money(amount: 1)
      |> ShippingRule.lens.estimatedMax .~ Money(amount: 5)

    let reward = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)
      |> Reward.lens.shippingRulesExpanded .~ [rewardShippingRule]
      |> Reward.lens.id .~ 99
    let addOn = Reward.template
      |> Reward.lens.shipping .~ (.template |> Reward.Shipping.lens.enabled .~ true)
      |> Reward.lens.id .~ 5
      |> Reward.lens.shippingRulesExpanded .~ [addOnShippingRule]

    let project = Project.template

    let selectedQuantities: SelectedRewardQuantities = [
      reward.id: 1,
      addOn.id: 2
    ]

    let estimatedShipping = estimatedShippingText(
      for: [reward, addOn],
      project: project,
      locationId: ShippingRule.template.location.id,
      selectedQuantities: selectedQuantities
    )

    XCTAssertEqual(estimatedShipping, "$3-$20")
  }

  func testSanitizedPledgeParameters_WithShipping() {
    let reward = Reward.template
    let selectedShippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 3.0
      |> ShippingRule.lens.location .~ (Location.template |> Location.lens.id .~ 123)

    let params = sanitizedPledgeParameters(
      from: [reward],
      selectedQuantities: [reward.id: 1],
      pledgeTotal: 13,
      shippingRule: selectedShippingRule
    )

    XCTAssertEqual(params.rewardIds, ["UmV3YXJkLTE="])
    XCTAssertEqual(params.pledgeTotal, "13.00")
    XCTAssertEqual(params.locationId, "123")
  }

  func testSanitizedPledgeParameters_WithShipping_WithAddOns() {
    let reward = Reward.template
    let selectedShippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 3.0
      |> ShippingRule.lens.location .~ (Location.template |> Location.lens.id .~ 123)

    let baseReward = Reward.template
      |> Reward.lens.id .~ 1
    let addOn1 = Reward.template
      |> Reward.lens.id .~ 2
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 3

    let params = sanitizedPledgeParameters(
      from: [baseReward, addOn1, addOn2],
      selectedQuantities: [reward.id: 1, addOn1.id: 2, addOn2.id: 1],
      pledgeTotal: 13,
      shippingRule: selectedShippingRule
    )

    XCTAssertEqual(
      params.rewardIds,
      ["UmV3YXJkLTE=", "UmV3YXJkLTI=", "UmV3YXJkLTI=", "UmV3YXJkLTM="]
    )
    XCTAssertEqual(params.pledgeTotal, "13.00")
    XCTAssertEqual(params.locationId, "123")
  }

  func testSanitizedPledgeParameters_NoShipping_NoReward() {
    let reward = Reward.noReward

    let params = sanitizedPledgeParameters(
      from: [reward],
      selectedQuantities: [reward.id: 1],
      pledgeTotal: 10,
      shippingRule: nil
    )

    XCTAssertEqual(params.rewardIds, ["UmV3YXJkLTA="])
    XCTAssertEqual(params.pledgeTotal, "10.00")
    XCTAssertNil(params.locationId)
  }

  func testRewardFromBackingWithProject_WhenRewardPresent() {
    let backing = Backing.template
      |> Backing.lens.reward .~ Reward.template
    let project = Project.template
      |> Project.lens.personalization.backing .~ backing

    XCTAssertEqual(Reward.template, reward(from: backing, inProject: project))
  }

  func testRewardFromBackingWithProject_WhenRewardIsNil() {
    let backing = Backing.template
      |> Backing.lens.reward .~ nil
      |> Backing.lens.rewardId .~ 123
    let backedReward = Reward.template
      |> Reward.lens.id .~ 123
    let project = Project.template
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.rewardData.rewards .~ [
        backedReward,
        Reward.template
          |> Reward.lens.id .~ 456
      ]

    XCTAssertEqual(backedReward, reward(from: backing, inProject: project))
  }

  func testRewardFromBackingWithProject_WhenRewardNotPresent_NoRewardPresent() {
    let backing = Backing.template
      |> Backing.lens.reward .~ nil
      |> Backing.lens.rewardId .~ 123
    let noReward = Reward.noReward
      |> Reward.lens.minimum .~ 10
    let project = Project.template
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.rewardData.rewards .~ [
        noReward, // No Reward "reward" is available
        Reward.template
          |> Reward.lens.id .~ 456
      ]

    XCTAssertEqual(noReward, reward(from: backing, inProject: project))
  }

  func testRewardFromBackingWithProject_WhenRewardNotPresent_NoRewardNotPresent() {
    let backing = Backing.template
      |> Backing.lens.reward .~ nil
      |> Backing.lens.rewardId .~ 123
    let project = Project.template
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.rewardData.rewards .~ [
        Reward.template
          |> Reward.lens.id .~ 456
      ]

    XCTAssertEqual(Reward.noReward, reward(from: backing, inProject: project))
  }

  func testRewardFromBackingWithProject_WhenRewardAndRewardIdAreNil() {
    let backing = Backing.template
      |> Backing.lens.reward .~ nil
      |> Backing.lens.rewardId .~ nil

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ []
      |> Project.lens.personalization.backing .~ backing

    XCTAssertEqual(
      Reward.noReward,
      reward(
        from: backing,
        inProject: project
      ),
      "Worst case when there are no rewards in the project, default to our local Reward.noReward"
    )
  }

  func testIsCurrentUserCreatorOfProject_IsCreator() {
    let creator = User.template
      |> User.lens.id .~ 5

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ creator

    withEnvironment(currentUser: creator) {
      XCTAssertTrue(currentUserIsCreator(of: project))
    }
  }

  func testIsCurrentUserCreatorOfProject_IsNotCreator() {
    let user = User.template
      |> User.lens.id .~ 5

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ (
        .template |> User.lens.id .~ 10
      )

    withEnvironment(currentUser: user) {
      XCTAssertFalse(currentUserIsCreator(of: project))
    }
  }

  func testDeviceIdentifier_IdentifierForVendor_IsNotNil() {
    withEnvironment(device: MockDevice()) {
      XCTAssertEqual("DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF", deviceIdentifier(uuid: MockUUID()))
    }
  }

  func testDeviceIdentifier_IdentifierForVendor_IsNil() {
    let device = MockDevice()
      |> \.identifierForVendor .~ nil

    withEnvironment(device: device) {
      XCTAssertEqual("ABCD-123", deviceIdentifier(uuid: MockUUID()))
    }
  }

  func testPledgeAmountSubtractingShippingAmount() {
    XCTAssertEqual(ksr_pledgeAmount(700.50, subtractingShippingAmount: 100), 600.50)
  }

  func testSelectedRewardQuantities_NoAddOns() {
    let reward = Reward.template
      |> Reward.lens.id .~ 99
    let backing = Backing.template
      |> Backing.lens.addOns .~ nil
      |> Backing.lens.reward .~ reward

    XCTAssertEqual(selectedRewardQuantities(in: backing), [reward.id: 1])
  }

  func testSelectedRewardQuantities_WithAddOns() {
    let reward = Reward.template
      |> Reward.lens.id .~ 99
    let addOn1 = Reward.template
      |> Reward.lens.id .~ 5
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 10
    let backing = Backing.template
      |> Backing.lens.addOns .~ [addOn1, addOn1, addOn2]
      |> Backing.lens.reward .~ reward

    let quantities = [
      reward.id: 1,
      addOn1.id: 2,
      addOn2.id: 1
    ]

    XCTAssertEqual(selectedRewardQuantities(in: backing), quantities)
  }

  func testRewardIsAvailable_NotLimitedBaseReward_NotBacked() {
    let reward = Reward.template
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.limitPerBacker .~ nil
      |> Reward.lens.isAvailable .~ true
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ nil

    XCTAssertEqual(rewardIsAvailable(reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), nil)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }

  func testRewardIsAvailable_NotLimitedBaseReward_Backed() {
    let reward = Reward.template
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.limitPerBacker .~ nil
      |> Reward.lens.isAvailable .~ true
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
      )

    XCTAssertEqual(rewardIsAvailable(reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), nil)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }

  func testRewardIsAvailable_LimitedBaseReward_NotBacked() {
    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ nil
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.isAvailable .~ false
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ nil

    XCTAssertEqual(rewardIsAvailable(reward), false)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), 0)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }

  func testRewardIsAvailable_LimitedBaseReward_Backed() {
    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ nil
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.isAvailable .~ true
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.addOns .~ nil
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
      )

    XCTAssertEqual(rewardIsAvailable(reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), 1)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }

  func testRewardIsAvailable_LimitedAddOnReward_Backed() {
    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ 5
      |> Reward.lens.limit .~ 4
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.isAvailable .~ true
    let project = Project.template
      |> Project.lens.rewardData.addOns .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ (reward |> Reward.lens.id .~ 99)
          |> Backing.lens.addOns .~ [reward, reward] // qty 2
      )

    XCTAssertEqual(rewardIsAvailable(reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), 2)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), 2)
  }

  func testRewardIsAvailable_LimitedAddOnReward_NotBacked() {
    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ 5
      |> Reward.lens.limit .~ 15
      |> Reward.lens.remaining .~ 4
      |> Reward.lens.isAvailable .~ true
    let project = Project.template
      |> Project.lens.rewardData.addOns .~ [reward]
      |> Project.lens.personalization.backing .~ nil

    XCTAssertEqual(rewardIsAvailable(reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), 4)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), 4)
  }

  func testRewardIsAvailable_Timebased_EndsInFuture() {
    let reward = Reward.template
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970 // ends in 5 secs
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.limitPerBacker .~ nil
      |> Reward.lens.isAvailable .~ true
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ nil

    XCTAssertEqual(rewardIsAvailable(reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), nil)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }

  func testRewardIsAvailable_Timebased_EndsInPast() {
    let reward = Reward.template
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(-5).timeIntervalSince1970 // ended 5 secs ago
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.limitPerBacker .~ nil
      |> Reward.lens.isAvailable .~ false
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ nil

    XCTAssertEqual(rewardIsAvailable(reward), false)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), nil)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }

  func testProjectCountryForCurrency() {
    let projectCountry = projectCountry(forCurrency: "MXN")

    XCTAssertEqual(projectCountry, .mx)
  }

  func testFormattedAmountForRewardOrBacking() {
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode

    let backing = Backing.template

    var currencyText = formattedAmountForRewardOrBacking(
      project: mexicanCurrencyProjectTemplate,
      rewardOrBacking: .right(backing)
    )

    XCTAssertEqual(currencyText, "MX$ 10")

    let reward = Reward.template
      |> Reward.lens.minimum .~ 12.00

    currencyText = formattedAmountForRewardOrBacking(
      project: mexicanCurrencyProjectTemplate,
      rewardOrBacking: .left(reward)
    )

    XCTAssertEqual(currencyText, "MX$ 12")
  }

  func testMinAndMaxPledgeAmount_NoReward_ProjectCurrencyCountry_isNotLatePledge_MinMaxPledgeReturned_Success(
  ) {
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode

    let (min, max) = minAndMaxPledgeAmount(forProject: mexicanCurrencyProjectTemplate, reward: nil)

    XCTAssertEqual(min, 10)
    XCTAssertEqual(max, 200_000)
  }

  func testMinAndMaxPledgeAmount_Reward_ProjectCurrencyCountry_isNotLatePledge_MinimumPledgeReturned_Success(
  ) {
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode

    let reward = Reward.template
      |> Reward.lens.minimum .~ 12.00

    let (min, max) = minAndMaxPledgeAmount(forProject: mexicanCurrencyProjectTemplate, reward: reward)

    XCTAssertEqual(min, 12)
    XCTAssertEqual(max, 200_000)
  }

  func testMinAndMaxPledgeAmount_Reward_ProjectCurrencyCountry_NoBacking_ProjectIsLatePledge_MinimumPledgeReturned_Success(
  ) {
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.isInPostCampaignPledgingPhase .~ true
      |> Project.lens.personalization.backing .~ nil

    let reward = Reward.template
      |> Reward.lens.minimum .~ 12.00
      |> Reward.lens.latePledgeAmount .~ 10.00
      |> Reward.lens.pledgeAmount .~ 6.00

    let (min, max) = minAndMaxPledgeAmount(forProject: mexicanCurrencyProjectTemplate, reward: reward)

    XCTAssertEqual(min, 12)
    XCTAssertEqual(max, 200_000)
  }

  func testMinAndMaxPledgeAmount_Reward_ProjectCurrencyCountry_isLatePledge_MinMaxLatePledgeAmountReturned_latePledgeAmount_Success(
  ) {
    let backing = Backing.template
      |> Backing.lens.isLatePledge .~ true
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.personalization.backing .~ backing

    let reward = Reward.template
      |> Reward.lens.minimum .~ 12.00
      |> Reward.lens.latePledgeAmount .~ 6.00

    let (min, max) = minAndMaxPledgeAmount(forProject: mexicanCurrencyProjectTemplate, reward: reward)

    XCTAssertEqual(min, 6)
    XCTAssertEqual(max, 200_000)
  }

  func testMinAndMaxPledgeAmount_Reward_ProjectCurrencyCountry_HasLatePledge_MinMaxPledgeAmountReturned_Success(
  ) {
    let backing = Backing.template
      |> Backing.lens.isLatePledge .~ false
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.personalization.backing .~ backing

    let reward = Reward.template
      |> Reward.lens.minimum .~ 12.00
      |> Reward.lens.latePledgeAmount .~ 6.00
      |> Reward.lens.pledgeAmount .~ 3.00

    let (min, max) = minAndMaxPledgeAmount(forProject: mexicanCurrencyProjectTemplate, reward: reward)

    XCTAssertEqual(min, 3)
    XCTAssertEqual(max, 200_000)
  }

  func testMinAndMaxPledgeAmount_NoReward_NoProjectCurrencyCountry_isNotLatePledge__DefaultMinMaxPledgeReturned_Success(
  ) {
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode

    let emptyLaunchedCountries = LaunchedCountries(countries: [])

    withEnvironment(launchedCountries: emptyLaunchedCountries) {
      let (min, max) = minAndMaxPledgeAmount(forProject: mexicanCurrencyProjectTemplate, reward: .noReward)

      XCTAssertEqual(min, 1)
      XCTAssertEqual(max, 10_000)
    }
  }

  func testEstimatedShippingText() {
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.stats.userCurrency .~ Project.Country.mx.currencyCode

    let backing = Backing.template

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.estimatedMin .~ Money(amount: 5.0)
      |> ShippingRule.lens.estimatedMax .~ Money(amount: 10.0)
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let estimatedShippingText = estimatedShippingText(
      for: [reward],
      project: mexicanCurrencyProjectTemplate,
      locationId: shippingRule.location.id,
      selectedQuantities: selectedRewardQuantities(in: backing) /// 2
    )

    XCTAssertEqual(estimatedShippingText, "MX$ 10-MX$ 20")
  }

  func testEstimatedShippingConversionText() {
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode

    let backing = Backing.template

    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.estimatedMin .~ Money(amount: 5.0)
      |> ShippingRule.lens.estimatedMax .~ Money(amount: 10.0)
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]

    let estimatedShippingText = estimatedShippingText(
      for: [reward],
      project: mexicanCurrencyProjectTemplate,
      locationId: shippingRule.location.id,
      selectedQuantities: selectedRewardQuantities(in: backing) /// 2
    )

    XCTAssertEqual(estimatedShippingText, "About $8-$15")
  }
}
