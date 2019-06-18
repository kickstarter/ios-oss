import UIKit

extension UIFeedbackGenerator {
  public static func ksr_generateImpactFeedback(style _: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    AppEnvironment.current.lightImpactFeedbackGenerator.impactOccurred()
  }

  public static func ksr_generateSelectionFeedback() {
    AppEnvironment.current.selectionFeedbackGenerator.selectionChanged()
  }

  public static func ksr_generateSuccessFeedback() {
    AppEnvironment.current.notificationFeedbackGenerator.notificationOccurred(.success)
  }

  public static func ksr_generateWarningFeedback() {
    AppEnvironment.current.notificationFeedbackGenerator.notificationOccurred(.warning)
  }
}
