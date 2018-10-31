import UIKit

@available(iOS 10.0, *)
extension UIFeedbackGenerator {
  public static func ksr_success() {
    UINotificationFeedbackGenerator().notificationOccurred(.success)
  }

  public static func ksr_selection() {
    UISelectionFeedbackGenerator().selectionChanged()
  }
}
