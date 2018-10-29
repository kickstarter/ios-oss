import KsApi
import Prelude

public enum UserAttribute {

  case newsletter(Newsletter)
  case notification(Notification)
  case privacy(Privacy)

  public var keyPath: WritableKeyPath<User, Bool?> {
    switch self {
    case let .newsletter(newsletter):
      switch newsletter {
      case .arts:       return \.newsletters.arts
      case .games:      return \.newsletters.games
      case .happening:  return \.newsletters.happening
      case .invent:     return \.newsletters.invent
      case .promo:      return \.newsletters.promo
      case .weekly:     return \.newsletters.weekly
      case .films:      return \.newsletters.films
      case .publishing: return \.newsletters.publishing
      case .alumni:     return \.newsletters.alumni
      }
    case let .notification(notification):
      switch notification {
      case .comments:             return \.notifications.comments
      case .creatorTips:          return \.notifications.creatorTips
      case .creatorDigest:        return \.notifications.creatorDigest
      case .follower:             return \.notifications.follower
      case .friendActivity:       return \.notifications.friendActivity
      case .messages:             return \.notifications.messages
      case .mobileComments:       return \.notifications.mobileComments
      case .mobileFollower:       return \.notifications.mobileFollower
      case .mobileFriendActivity: return \.notifications.mobileFriendActivity
      case .mobileMessages:       return \.notifications.mobileMessages
      case .mobilePledgeActivity: return \.notifications.mobileBackings
      case .mobilePostLikes:      return \.notifications.mobilePostLikes
      case .mobileUpdates:        return \.notifications.mobileUpdates
      case .pledgeActivity:       return \.notifications.backings
      case .postLikes:            return \.notifications.postLikes
      case .updates:              return \.notifications.updates
      }
    case let .privacy(privacy):
      switch privacy {
      case .following:          return \.social
      case .recommendations:    return \.optedOutOfRecommendations
      case .showPublicProfile:  return \.showPublicProfile
      }
    }
  }

  public enum Notification {
    case comments
    case creatorDigest
    case creatorTips
    case follower
    case friendActivity
    case messages
    case mobileComments
    case mobileFollower
    case mobileFriendActivity
    case mobileMessages
    case mobilePledgeActivity
    case mobilePostLikes
    case mobileUpdates
    case pledgeActivity
    case postLikes
    case updates

    public var trackingString: String {
      switch self {
      case .comments, .mobileComments:                return "New comments"
      case .creatorDigest:                            return "Creator digest"
      case .creatorTips:                              return "Creator tips"
      case .follower, .mobileFollower:                return "New followers"
      case .friendActivity, .mobileFriendActivity:    return "Friend backs a project"
      case .messages, .mobileMessages:                return "New messages"
      case .pledgeActivity, .mobilePledgeActivity:    return "New pledges"
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
