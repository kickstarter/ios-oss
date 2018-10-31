import UIKit

@available(iOS 10.0, *)
extension UIFeedbackGenerator {
  public func ksr_successFeedbackGenerator() {
   UINotificationFeedbackGenerator().notificationOccurred(.success)
  }
}
