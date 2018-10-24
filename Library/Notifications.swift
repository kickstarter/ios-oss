import Foundation

public enum CurrentUserNotifications {
  public static let showNotificationsDialog = "CurrentUserNotifications.showNotificationsDialog"
  public static let projectSaved = "CurrentUserNotifications.projectSaved"
  public static let dataRequested = "CurrentUserNotifications.dataRequested"
  public static let savedProjectEmptyStateTapped = "CurrentUserNotifications.savedProjectEmptyStateTapped"
  public static let sessionStarted = "CurrentUserNotifications.sessionStarted"
  public static let sessionEnded = "CurrentUserNotifications.sessionEnded"
  public static let userUpdated = "CurrentUserNotifications.userUpdated"
  public static let languageChanged = "CurrentUserNotification.languageChanged"
  public static let environmentChanged = "CurrentUserNotification.environmentChanged"
}

public enum UserInfoKeys {
  public static let context = "UserInfoKeys.context"
  public static let viewController = "UserInfoKeys.viewController"
}

extension Notification.Name {
  public static let ksr_sessionStarted = Notification.Name(rawValue: CurrentUserNotifications.sessionStarted)
  public static let ksr_sessionEnded = Notification.Name(rawValue: CurrentUserNotifications.sessionEnded)
  public static let ksr_userUpdated = Notification.Name(rawValue: CurrentUserNotifications.userUpdated)
  public static let ksr_projectSaved = Notification.Name(rawValue: CurrentUserNotifications.projectSaved)
  public static let ksr_dataRequested = Notification.Name(rawValue: CurrentUserNotifications.dataRequested)
  public static let ksr_savedProjectEmptyStateTapped =
    Notification.Name(rawValue: CurrentUserNotifications.savedProjectEmptyStateTapped)
  public static let ksr_showNotificationsDialog =
    Notification.Name(rawValue: CurrentUserNotifications.showNotificationsDialog)
  public static let ksr_languageChanged = Notification.Name(rawValue:
    CurrentUserNotifications.languageChanged
  )
  public static let ksr_environmentChanged = Notification.Name(rawValue:
    CurrentUserNotifications.environmentChanged
  )
}
