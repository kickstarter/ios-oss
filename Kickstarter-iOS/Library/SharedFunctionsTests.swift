@testable import Kickstarter_Framework
@testable import Library
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
}
