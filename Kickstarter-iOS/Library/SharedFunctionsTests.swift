@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi
import XCTest
import Prelude

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
    let project = Project.template
    let selectedShippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 3
      |> ShippingRule.lens.location .~ (Location.template |> Location.lens.id .~ 123)

    let params = formattedPledgeParameters(from: project,
                                           reward: reward,
                                           pledgeAmount: 10,
                                           selectedShippingRule: selectedShippingRule)

    XCTAssertEqual(params.projectId, "UHJvamVjdC0x")
    XCTAssertEqual(params.rewardId, "UmV3YXJkLTE=")
    XCTAssertEqual(params.pledgeTotal, "13.00")
    XCTAssertEqual(params.locationId, "123")
  }

  func testFormattedPledgeParameters_NoShipping_NoReward() {
    let reward = Reward.noReward
    let project = Project.template

    let params = formattedPledgeParameters(from: project,
                                           reward: reward,
                                           pledgeAmount: 10,
                                           selectedShippingRule: nil)

    XCTAssertEqual(params.projectId, "UHJvamVjdC0x")
    XCTAssertNil(params.rewardId)
    XCTAssertEqual(params.pledgeTotal, "10.00")
    XCTAssertNil(params.locationId)
  }
}
