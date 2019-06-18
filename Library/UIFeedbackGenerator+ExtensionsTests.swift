@testable import Library
import XCTest

final class UIFeedbackGeneratorTests: TestCase {
  func testImpactOccured() {
    let mockFeedbackGenerator = MockLightImpactFeedbackGenerator()

    withEnvironment(lightImpactFeedbackGenerator: mockFeedbackGenerator) {
      UIFeedbackGenerator.ksr_generateImpactFeedback()

      XCTAssertEqual(true, mockFeedbackGenerator.impactOccurredWasCalled)
    }
  }

  func testSelection() {
    let mockFeedbackGenerator = MockSelectionFeedbackGenerator()

    withEnvironment(selectionFeedbackGenerator: mockFeedbackGenerator) {
      UIFeedbackGenerator.ksr_generateSelectionFeedback()

      XCTAssertEqual(true, mockFeedbackGenerator.selectionChangedWasCalled)
    }
  }

  func testSuccess() {
    let mockFeedbackGenerator = MockNotificationFeedbackGenerator()

    withEnvironment(notificationFeedbackGenerator: mockFeedbackGenerator) {
      UIFeedbackGenerator.ksr_generateSuccessFeedback()

      XCTAssertEqual(true, mockFeedbackGenerator.notificationOccuredWasCalled)
    }
  }

  func testWarning() {
    let mockFeedbackGenerator = MockNotificationFeedbackGenerator()

    withEnvironment(notificationFeedbackGenerator: mockFeedbackGenerator) {
      UIFeedbackGenerator.ksr_generateWarningFeedback()

      XCTAssertEqual(true, mockFeedbackGenerator.notificationOccuredWasCalled)
    }
  }
}
