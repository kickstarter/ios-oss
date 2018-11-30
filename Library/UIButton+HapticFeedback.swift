import UIKit

extension UIButton {
  public func generateSelectionFeedback() {
    UIFeedbackGenerator.ksr_selection()
  }

  public func generateSuccessFeedback() {
    UIFeedbackGenerator.ksr_success()
  }

  @available(iOS 10.0, *)
  public func generateImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
      UIFeedbackGenerator.ksr_impact(style: style)
  }
}
