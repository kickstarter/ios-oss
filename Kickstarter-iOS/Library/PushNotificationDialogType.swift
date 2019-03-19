import Foundation
import Library

public protocol PushNotificationDialogType {
  static func resetAllContexts()
}

extension PushNotificationDialog: PushNotificationDialogType {
  public var pushNotificationDialog: PushNotificationDialog {
    return self
  }
}
