import UIKit

// MARK: - UIFeedbackGenerator

protocol UIFeedbackGeneratorType {
  func prepare()
}

// MARK: - UIImpactFeedbackGeneratorType

protocol UIImpactFeedbackGeneratorType: UIFeedbackGeneratorType {
  func impactOccurred()
}

extension UIImpactFeedbackGenerator: UIImpactFeedbackGeneratorType {}

// MARK: - UINotificationFeedbackGeneratorType

protocol UINotificationFeedbackGeneratorType: UIFeedbackGeneratorType {
  func notificationOccurred(_ notificationType: UINotificationFeedbackGenerator.FeedbackType)
}

extension UINotificationFeedbackGenerator: UINotificationFeedbackGeneratorType {}

// MARK: - UISelectionFeedbackGeneratorType

protocol UISelectionFeedbackGeneratorType: UIFeedbackGeneratorType {
  func selectionChanged()
}

extension UISelectionFeedbackGenerator: UISelectionFeedbackGeneratorType {}
