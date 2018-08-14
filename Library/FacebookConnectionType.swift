public enum FacebookConnectionType {
  case connect
  case reconnect

  var titleText: String {
    switch self {
    case .connect:
      return Strings.Discover_more_projects()
    case .reconnect:
      return Strings.Facebook_reconnect()
    }
  }

  var subtitleText: String {
    switch self {
    case .connect:
      return Strings.Connect_with_Facebook_to_follow_friends_and_get_notified()
    case .reconnect:
      return Strings.Facebook_reconnect_description()
    }
  }

  var buttonText: String {
    return Strings.general_social_buttons_connect_with_facebook()
  }
}
