import Foundation

public struct PushNotificationDialog {

  public enum Context: String {
    case login
    case message
    case pledge
    case save
  }

  private static var contexts: [String] = AppEnvironment.current.userDefaults.deniedNotificationDialogContexts

  static public func canShowDialog(`for` context: PushNotificationDialog.Context) -> Bool {
    return AppEnvironment.current.userDefaults.deniedNotificationDialogContexts.contains(context.rawValue) &&
            AppEnvironment.current.userDefaults.deniedNotificationDialogContexts.count < 3
  }

  static public func didDenyAccess(`for` context: Context) {

    guard AppEnvironment.current.userDefaults.deniedNotificationDialogContexts.contains(context.rawValue) else {
      return
    }
    AppEnvironment.current.userDefaults.deniedNotificationDialogContexts.append(context.rawValue)
  }

  static public var titleForDismissal: String {
    return AppEnvironment.current.userDefaults.deniedNotificationDialogContexts.count < 2 ? "Not Now" : "Never"
  }
}

extension PushNotificationDialog.Context {

  public var title: String {
    switch self {
    case .login: return "login title"
    case .message: return "message title"
    case .pledge: return "pledge title"
    case .save: return "save title"
    }
  }

  public var message: String {
    switch self {
    case .login: return "login message"
    case .message: return "message message"
    case .pledge: return "pledge message"
    case .save: return "save message"
    }
  }
}
