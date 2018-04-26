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
    return !PushNotificationDialog.contexts.contains(context.rawValue) &&
            PushNotificationDialog.contexts.count < 3
  }

  static public func didDenyAccess(`for` context: Context) {

    guard !PushNotificationDialog.contexts.contains(context.rawValue) else {
      return
    }
    PushNotificationDialog.contexts.append(context.rawValue)
  }

  static public var titleForDismissal: String {
    return PushNotificationDialog.contexts.count < 3 ? "Not Now" : "Never"
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
