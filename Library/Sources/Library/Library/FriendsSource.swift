public enum FriendsSource {
  case discovery
  case findFriends
  case settings

  public var trackingString: String {
    switch self {
    case .discovery: return "discovery"
    case .findFriends: return "find-friends"
    case .settings: return "settings"
    }
  }
}
