import Foundation

public struct PushNotificationDialog: PushNotificationDialogType {
  public enum Context: String {
    case login
    case message
    case pledge
    case save
  }

  private static let maxDeniedContexts: Int = 3

  public static func canShowDialog(for context: PushNotificationDialog.Context) -> Bool {
    return (!AppEnvironment.current.userDefaults.deniedNotificationContexts.contains(context.rawValue) &&
      AppEnvironment.current.userDefaults.deniedNotificationContexts.count < self.maxDeniedContexts)
  }

  public static func didDenyAccess(for context: Context) {
    if !AppEnvironment.current.userDefaults.deniedNotificationContexts.contains(context.rawValue) {
      AppEnvironment.current.userDefaults.deniedNotificationContexts.append(context.rawValue)
    }
  }

  public static func resetAllContexts() {
    AppEnvironment.current.userDefaults.deniedNotificationContexts.removeAll()
  }

  public static var titleForDismissal: String {
    return (
      AppEnvironment.current.userDefaults.deniedNotificationContexts.count < 2
    ) ? Strings.Not_now() : Strings.Never()
  }
}

extension PushNotificationDialog.Context {
  public var title: String {
    switch self {
    case .login: return Strings.Stay_up_to_date()
    case .message: return Strings.Get_notified_about_new_messages()
    case .pledge: return Strings.Stay_updated_on_this_project()
    case .save: return Strings.Get_reminded_about_this_project()
    }
  }

  public var message: String {
    switch self {
    case .login: return Strings.Receive_project_updates_messages_and_more()
    case .message: return Strings.Know_when_creators_and_backers_message_you()
    case .pledge: return Strings.Receive_project_updates_and_more()
    case .save: return Strings.Receive_a_reminder_forty_eight_hours_before_this_project_ends()
    }
  }
}
