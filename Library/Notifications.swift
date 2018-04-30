import Foundation

public enum CurrentUserNotifications {
  public static let showNotificationsDialog = "CurrentUserNotifications.showNotificationsDialog"
  public static let projectSaved = "CurrentUserNotifications.projectSaved"
  public static let sessionStarted = "CurrentUserNotifications.sessionStarted"
  public static let sessionEnded = "CurrentUserNotifications.sessionEnded"
  public static let userUpdated = "CurrentUserNotifications.userUpdated"
}

public enum UserInfoKeys {
  public static let context = "UserInfoKeys.context"
}

extension Notification.Name {
  public static let ksr_sessionStarted = Notification.Name(rawValue: CurrentUserNotifications.sessionStarted)
  public static let ksr_sessionEnded = Notification.Name(rawValue: CurrentUserNotifications.sessionEnded)
  public static let ksr_userUpdated = Notification.Name(rawValue: CurrentUserNotifications.userUpdated)
  public static let ksr_projectSaved = Notification.Name(rawValue: CurrentUserNotifications.projectSaved)
  public static let ksr_showNotificationsDialog =
    Notification.Name(rawValue: CurrentUserNotifications.showNotificationsDialog)
}
