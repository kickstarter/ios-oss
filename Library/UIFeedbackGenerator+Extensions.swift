import UIKit

extension UIFeedbackGenerator {
  public static func ksr_success() {
    UINotificationFeedbackGenerator().notificationOccurred(.success)
  }

  public static func ksr_selection() {
    UISelectionFeedbackGenerator().selectionChanged()
  }

  public static func ksr_impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
  }
}
