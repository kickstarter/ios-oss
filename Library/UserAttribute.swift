import KsApi
import Prelude

public enum UserAttribute {

  case newsletter(Newsletter)
  case notification(Notification)
  case privacy(Privacy)

  public var lens: Lens<User, Bool?> {
    switch self {
    case let .newsletter(newsletter):
      switch newsletter {
      case .arts:       return User.lens.newsletters.arts
      case .games:      return User.lens.newsletters.games
      case .happening:  return User.lens.newsletters.happening
      case .invent:     return User.lens.newsletters.invent
      case .promo:      return User.lens.newsletters.promo
      case .weekly:     return User.lens.newsletters.weekly
      }
    case let .notification(notification):
      switch notification {
      case .backings:             return User.lens.notifications.backings
      case .comments:             return User.lens.notifications.comments
      case .creatorTips:          return User.lens.notifications.creatorTips
      case .creatorDigest:        return User.lens.notifications.creatorDigest
      case .follower:             return User.lens.notifications.follower
      case .friendActivity:       return User.lens.notifications.friendActivity
      case .messages:             return User.lens.notifications.messages
      case .mobileBackings:       return User.lens.notifications.mobileBackings
      case .mobileComments:       return User.lens.notifications.mobileComments
      case .mobileFollower:       return User.lens.notifications.mobileFollower
      case .mobileFriendActivity: return User.lens.notifications.mobileFriendActivity
      case .mobileMessages:       return User.lens.notifications.mobileMessages
      case .mobilePostLikes:      return User.lens.notifications.mobilePostLikes
      case .mobileUpdates:        return User.lens.notifications.mobileUpdates
      case .postLikes:            return User.lens.notifications.postLikes
      case .updates:              return User.lens.notifications.updates
      }
    case let .privacy(privacy):
      switch privacy {
      case .following:          return User.lens.social
      case .recommendations:    return User.lens.optedOutOfRecommendations
      case .showPublicProfile:  return User.lens.showPublicProfile
      }
    }
  }

  public enum Notification {
    case backings
    case comments
    case creatorDigest
    case creatorTips
    case follower
    case friendActivity
    case messages
    case mobileBackings
    case mobileComments
    case mobileFollower
    case mobileFriendActivity
    case mobileMessages
    case mobilePostLikes
    case mobileUpdates
    case postLikes
    case updates

    public var trackingString: String {
      switch self {
      case .backings, .mobileBackings:                return "New pledges"
      case .comments, .mobileComments:                return "New comments"
      case .creatorDigest:                            return "Creator digest"
      case .creatorTips:                              return "Creator tips"
      case .follower, .mobileFollower:                return "New followers"
      case .friendActivity, .mobileFriendActivity:    return "Friend backs a project"
      case .messages, .mobileMessages:                return "New messages"
      case .postLikes, .mobilePostLikes:              return "New likes"
      case .updates, .mobileUpdates:                  return "Project updates"
      }
    }
  }

  public enum Privacy {
    case following
    case recommendations
    case showPublicProfile

    public var trackingString: String {
      switch self {
      case .following: return Strings.Following()
      case .recommendations: return Strings.Recommendations()
      default: return ""
      }
    }
  }
}
