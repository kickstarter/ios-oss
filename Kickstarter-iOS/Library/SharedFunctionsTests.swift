@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class SharedFunctionsTests: TestCase {
  func testGenerateImpactFeedback() {
    let mockFeedbackGenerator = MockImpactFeedbackGenerator()

    generateImpactFeedback(feedbackGenerator: mockFeedbackGenerator)

    XCTAssertTrue(mockFeedbackGenerator.prepareWasCalled)
    XCTAssertTrue(mockFeedbackGenerator.impactOccurredWasCalled)
  }

  func testGenerateNotificationSuccessFeedback() {
    let mockFeedbackGenerator = MockNotificationFeedbackGenerator()

    generateNotificationSuccessFeedback(feedbackGenerator: mockFeedbackGenerator)

    XCTAssertTrue(mockFeedbackGenerator.prepareWasCalled)
    XCTAssertTrue(mockFeedbackGenerator.notificationOccurredWasCalled)
  }

  func testGenerateNotificationWarningFeedback() {
    let mockFeedbackGenerator = MockNotificationFeedbackGenerator()

    generateNotificationWarningFeedback(feedbackGenerator: mockFeedbackGenerator)

    XCTAssertTrue(mockFeedbackGenerator.prepareWasCalled)
    XCTAssertTrue(mockFeedbackGenerator.notificationOccurredWasCalled)
  }

  func testGenerateSelectionFeedback() {
    let mockFeedbackGenerator = MockSelectionFeedbackGenerator()

    generateSelectionFeedback(feedbackGenerator: mockFeedbackGenerator)

    XCTAssertTrue(mockFeedbackGenerator.prepareWasCalled)
    XCTAssertTrue(mockFeedbackGenerator.selectionChangedWasCalled)
  }

  func testLogoutAndDismiss() {
    let mockAppEnvironment = MockAppEnvironment.self
    let mockPushNotificationDialog = MockPushNotificationDialog.self
    let mockViewController = MockViewController()

    XCTAssertFalse(mockAppEnvironment.logoutWasCalled)
    XCTAssertFalse(mockPushNotificationDialog.resetAllContextsWasCalled)
    XCTAssertFalse(mockViewController.dismissAnimatedWasCalled)
    logoutAndDismiss(
      viewController: mockViewController, appEnvironment: mockAppEnvironment,
      pushNotificationDialog: mockPushNotificationDialog
    )
    XCTAssertTrue(mockAppEnvironment.logoutWasCalled)
    XCTAssertTrue(mockPushNotificationDialog.resetAllContextsWasCalled)
    XCTAssertTrue(mockViewController.dismissAnimatedWasCalled)
  }

  func testUserNotificationCenterDidReceiveResponse_AppboyIsNil() {
    var calledIsNotNilPath = false
    var calledIsNilPath = false

    userNotificationCenterDidReceiveResponse(appBoy: nil) {
      calledIsNotNilPath = true
    } isNil: {
      calledIsNilPath = true
    }

    XCTAssertFalse(calledIsNotNilPath)
    XCTAssertTrue(calledIsNilPath)
  }

  func testUserNotificationCenterDidReceiveResponse_AppboyIsNotNil() {
    var calledIsNotNilPath = false
    var calledIsNilPath = false

    userNotificationCenterDidReceiveResponse(appBoy: MockAppboy()) {
      calledIsNotNilPath = true
    } isNil: {
      calledIsNilPath = true
    }

    XCTAssertTrue(calledIsNotNilPath)
    XCTAssertFalse(calledIsNilPath)
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

  func testDiscoveryPageBackgroundColor() {
    XCTAssertEqual(discoveryPageBackgroundColor(), LegacyColors.ksr_white.uiColor())
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
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode

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
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode

    let (min, max) = minAndMaxPledgeAmount(forProject: mexicanCurrencyProjectTemplate, reward: nil)

    XCTAssertEqual(min, 10)
    XCTAssertEqual(max, 200_000)
  }

  func testMinAndMaxPledgeAmount_Reward_ProjectCurrencyCountry_isNotLatePledge_MinimumPledgeReturned_Success(
  ) {
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode

    let reward = Reward.template
      |> Reward.lens.minimum .~ 12.00

    let (min, max) = minAndMaxPledgeAmount(forProject: mexicanCurrencyProjectTemplate, reward: reward)

    XCTAssertEqual(min, 12)
    XCTAssertEqual(max, 200_000)
  }

  func testMinAndMaxPledgeAmount_Reward_ProjectCurrencyCountry_NoBacking_ProjectIsLatePledge_MinimumPledgeReturned_Success(
  ) {
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
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
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
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
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
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
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode

    let emptyLaunchedCountries = LaunchedCountries(countries: [])

    withEnvironment(launchedCountries: emptyLaunchedCountries) {
      let (min, max) = minAndMaxPledgeAmount(forProject: mexicanCurrencyProjectTemplate, reward: .noReward)

      XCTAssertEqual(min, 1)
      XCTAssertEqual(max, 10_000)
    }
  }

  func testEstimatedShippingText() {
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.mx.currencyCode

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

    XCTAssertEqual(estimatedShippingText, "US$ 10-US$ 20")
  }

  func testEstimatedShippingConversionText() {
    let mexicanCurrencyProjectTemplate = Project.template
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode

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
