import AppboyKit
import Library
import UIKit

// MARK: - Haptic feedback

func generateImpactFeedback(
  feedbackGenerator: UIImpactFeedbackGeneratorType = UIImpactFeedbackGenerator(style: .light)
) {
  feedbackGenerator.prepare()
  feedbackGenerator.impactOccurred()
}

func generateNotificationSuccessFeedback(
  feedbackGenerator: UINotificationFeedbackGeneratorType = UINotificationFeedbackGenerator()
) {
  feedbackGenerator.prepare()
  feedbackGenerator.notificationOccurred(.success)
}

func generateNotificationWarningFeedback(
  feedbackGenerator: UINotificationFeedbackGeneratorType = UINotificationFeedbackGenerator()
) {
  feedbackGenerator.prepare()
  feedbackGenerator.notificationOccurred(.warning)
}

func generateSelectionFeedback(
  feedbackGenerator: UISelectionFeedbackGeneratorType = UISelectionFeedbackGenerator()
) {
  feedbackGenerator.prepare()
  feedbackGenerator.selectionChanged()
}

// MARK: - Login workflow

public func logoutAndDismiss(
  viewController: UIViewController,
  appEnvironment: AppEnvironmentType.Type = AppEnvironment.self,
  pushNotificationDialog: PushNotificationDialogType.Type =
    PushNotificationDialog.self
) {
  appEnvironment.logout()

  pushNotificationDialog.resetAllContexts()

  NotificationCenter.default.post(.init(name: .ksr_sessionEnded))

  viewController.dismiss(animated: true, completion: nil)
}

// MARK: - Braze

public func userNotificationCenterDidReceiveResponse(
  appBoy: AppboyType?,
  isNotNil: () -> (),
  isNil: () -> ()
) {
  appBoy == nil ? isNil() : isNotNil()
}
