import UIKit

extension UIButton {

  @available(iOS 10.0, *)
  public func generateSelectionFeedback() {
    UISelectionFeedbackGenerator().selectionChanged()
  }

  @available(iOS 10.0, *)
  public func generateSuccessFeedback() {
    UINotificationFeedbackGenerator().notificationOccurred(.success)
  }
}
