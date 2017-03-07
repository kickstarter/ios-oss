public enum LoginIntent: String {
  case activity
  case backProject
  case discoveryOnboarding
  case favoriteCategory
  case generic
  case liveStreamChat
  case liveStreamSubscribe
  case loginTab
  case messageCreator
  case starProject

  var trackingString: String {
    switch self {
    case .activity:
      return "activity"
    case .backProject:
      return "pledge"
    case .discoveryOnboarding:
      return "discovery_prompt"
    case .favoriteCategory:
      return "favorite_category"
    case .generic:
      return "generic"
    case .liveStreamChat:
      return "live_stream_chat"
    case .liveStreamSubscribe:
      return "live_stream_subscribe"
    case .loginTab:
      return "login_tab"
    case .messageCreator:
      return "message_creator"
    case .starProject:
      return "star"
    }
  }
}
