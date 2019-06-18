@testable import Library
import UIKit

class MockLightImpactFeedbackGenerator: UIImpactFeedbackGeneratorType {
  // MARK: - Properties

  var impactOccurredWasCalled = false

  // MARK: - UIImpactFeedbackGeneratorType

  func impactOccurred() {
    self.impactOccurredWasCalled = true
  }
}

class MockSelectionFeedbackGenerator: UISelectionFeedbackGeneratorType {
  // MARK: - Properties

  var selectionChangedWasCalled = false

  // MARK: - UISelectionFeedbackGeneratorType

  func selectionChanged() {
    self.selectionChangedWasCalled = true
  }
}

class MockNotificationFeedbackGenerator: UINotificationFeedbackGeneratorType {
  // MARK: - Properties

  var notificationOccuredWasCalled = false

  // MARK: - UINotificationFeedbackGeneratorType

  func notificationOccurred(_: UINotificationFeedbackGenerator.FeedbackType) {
    self.notificationOccuredWasCalled = true
  }
}
