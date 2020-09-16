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

  func testDiscoveryPageBackgroundColor_Control() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectCards.rawValue:
          OptimizelyExperiment.Variant.control.rawValue
      ]

    withEnvironment(optimizelyClient: optimizelyClient) {
      XCTAssertEqual(discoveryPageBackgroundColor(), .white)
    }
  }

  func testDiscoveryPageBackgroundColor_Variant1() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectCards.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(optimizelyClient: optimizelyClient) {
      XCTAssertEqual(discoveryPageBackgroundColor(), .ksr_grey_200)
    }
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
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ nil

    XCTAssertEqual(rewardIsAvailable(project: project, reward: reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), nil)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }

  func testRewardIsAvailable_NotLimitedBaseReward_Backed() {
    let reward = Reward.template
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.limitPerBacker .~ nil
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
      )

    XCTAssertEqual(rewardIsAvailable(project: project, reward: reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), nil)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }

  func testRewardIsAvailable_LimitedBaseReward_NotBacked() {
    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ nil
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 0
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ nil

    XCTAssertEqual(rewardIsAvailable(project: project, reward: reward), false)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), 0)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }

  func testRewardIsAvailable_LimitedBaseReward_Backed() {
    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ nil
      |> Reward.lens.limit .~ 5
      |> Reward.lens.remaining .~ 0
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.addOns .~ nil
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
      )

    XCTAssertEqual(rewardIsAvailable(project: project, reward: reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), 1)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }

  func testRewardIsAvailable_LimitedAddOnReward_Backed() {
    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ 5
      |> Reward.lens.limit .~ 4
      |> Reward.lens.remaining .~ 0
    let project = Project.template
      |> Project.lens.rewardData.addOns .~ [reward]
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ (reward |> Reward.lens.id .~ 99)
          |> Backing.lens.addOns .~ [reward, reward] // qty 2
      )

    XCTAssertEqual(rewardIsAvailable(project: project, reward: reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), 2)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), 2)
  }

  func testRewardIsAvailable_LimitedAddOnReward_NotBacked() {
    let reward = Reward.template
      |> Reward.lens.limitPerBacker .~ 5
      |> Reward.lens.limit .~ 15
      |> Reward.lens.remaining .~ 4
    let project = Project.template
      |> Project.lens.rewardData.addOns .~ [reward]
      |> Project.lens.personalization.backing .~ nil

    XCTAssertEqual(rewardIsAvailable(project: project, reward: reward), true)
    XCTAssertEqual(rewardIsAvailable(project: project, reward: reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), 4)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), 4)
  }

  func testRewardIsAvailable_Timebased_EndsInFuture() {
    let reward = Reward.template
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(5).timeIntervalSince1970 // ends in 5 secs
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.limitPerBacker .~ nil
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ nil

    XCTAssertEqual(rewardIsAvailable(project: project, reward: reward), true)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), nil)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }

  func testRewardIsAvailable_Timebased_EndsInPast() {
    let reward = Reward.template
      |> Reward.lens.endsAt .~ MockDate().addingTimeInterval(-5).timeIntervalSince1970 // ended 5 secs ago
      |> Reward.lens.limit .~ nil
      |> Reward.lens.remaining .~ nil
      |> Reward.lens.limitPerBacker .~ nil
    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.backing .~ nil

    XCTAssertEqual(rewardIsAvailable(project: project, reward: reward), false)
    XCTAssertEqual(rewardLimitRemainingForBacker(project: project, reward: reward), nil)
    XCTAssertEqual(rewardLimitPerBackerRemainingForBacker(project: project, reward: reward), nil)
  }
}
