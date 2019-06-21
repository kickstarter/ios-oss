import Foundation
@testable import Kickstarter_Framework
import UIKit

class MockImpactFeedbackGenerator: UIImpactFeedbackGeneratorType {
  var prepareWasCalled = false
  var impactOccurredWasCalled = false

  func prepare() {
    self.prepareWasCalled = true
  }

  func impactOccurred() {
    self.impactOccurredWasCalled = true
  }
}

class MockNotificationFeedbackGenerator: UINotificationFeedbackGeneratorType {
  var prepareWasCalled = false
  var notificationOccurredWasCalled = false

  func prepare() {
    self.prepareWasCalled = true
  }

  func notificationOccurred(_: UINotificationFeedbackGenerator.FeedbackType) {
    self.notificationOccurredWasCalled = true
  }
}

class MockSelectionFeedbackGenerator: UISelectionFeedbackGeneratorType {
  var prepareWasCalled = false
  var selectionChangedWasCalled = false

  func prepare() {
    self.prepareWasCalled = true
  }

  func selectionChanged() {
    self.selectionChangedWasCalled = true
  }
}
