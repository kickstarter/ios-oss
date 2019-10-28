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
      |> ShippingRule.lens.cost .~ 3
      |> ShippingRule.lens.location .~ (Location.template |> Location.lens.id .~ 123)

    let params = sanitizedPledgeParameters(
      from: reward,
      pledgeAmount: 10,
      selectedShippingRule: selectedShippingRule
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
      selectedShippingRule: nil
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

  func testRewardFromBackingWithProject_WhenRewardNotPresent() {
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
      |> Project.lens.personalization.backing .~ backing

    XCTAssertEqual(Reward.noReward, reward(from: backing, inProject: project))
  }
}
