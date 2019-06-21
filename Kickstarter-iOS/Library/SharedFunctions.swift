import Library
import UIKit

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
