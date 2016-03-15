public enum LoginIntent {
  case Activity
  case BackProject
  case FavoriteCategory
  case Generic
  case LoginTab
  case MessageCreator
  case StarProject
}

public extension LoginIntent {
  public func trackingString() -> String {
    switch self {
    case .Activity:         return "activity"
    case .BackProject:      return "pledge"
    case .FavoriteCategory: return "favorite_category"
    case .Generic:          return "generic"
    case .LoginTab:         return "login_tab"
    case .MessageCreator:   return "new_message"
    case .StarProject:      return "star"
    }
  }
}

