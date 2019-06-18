import UIKit

public protocol UIImpactFeedbackGeneratorType {
  func impactOccurred()
}

extension UIImpactFeedbackGenerator: UIImpactFeedbackGeneratorType {}

public protocol UISelectionFeedbackGeneratorType {
  func selectionChanged()
}

extension UISelectionFeedbackGenerator: UISelectionFeedbackGeneratorType {}

public protocol UINotificationFeedbackGeneratorType {
  func notificationOccurred(_ notificationType: UINotificationFeedbackGenerator.FeedbackType)
}

extension UINotificationFeedbackGenerator: UINotificationFeedbackGeneratorType {}
