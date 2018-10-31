import UIKit

extension UIButton {
  public func generateSelectionFeedback() {
    if #available(iOS 10.0, *) {
      UIFeedbackGenerator.ksr_selection()
    }
  }

  public func generateSuccessFeedback() {
    if #available(iOS 10.0, *) {
      UIFeedbackGenerator.ksr_success()
    }
  }
}
