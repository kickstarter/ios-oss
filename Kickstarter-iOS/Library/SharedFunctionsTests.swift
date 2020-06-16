@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class SharedFunctionsTests: XCTestCase {
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

  func testFormattedPledgeParameters_WithShipping() {
    let reward = Reward.template
    let selectedShippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 3.0
      |> ShippingRule.lens.location .~ (Location.template |> Location.lens.id .~ 123)

    let params = sanitizedPledgeParameters(
      from: reward,
      pledgeAmount: 10,
      shippingRule: selectedShippingRule
    )

    XCTAssertEqual(params.rewardId, "UmV3YXJkLTE=")
    XCTAssertEqual(params.pledgeTotal, "13.00")
    XCTAssertEqual(params.locationId, "123")
  }

  func testFormattedPledgeParameters_NoShipping_NoReward() {
    let reward = Reward.noReward

    let params = sanitizedPledgeParameters(
      from: reward,
      pledgeAmount: 10,
      shippingRule: nil
    )

    XCTAssertEqual(params.rewardId, "UmV3YXJkLTA=")
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
      |> Project.lens.rewards .~ [
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
      |> Project.lens.rewards .~ [
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
      |> Project.lens.rewards .~ [
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
      |> Project.lens.rewards .~ []
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
}
