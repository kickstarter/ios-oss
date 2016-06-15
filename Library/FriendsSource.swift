public enum FriendsSource {
  case activity
  case discovery
  case findFriends
  case settings

  public var trackingString: String {
    switch self {
    case .activity:     return "activity"
    case .discovery:    return "discovery"
    case .findFriends:  return "find-friends"
    case .settings:     return "settings"
    }
  }
}
