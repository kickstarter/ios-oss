import Argo
import Curry
import Runes

public struct User {
  public let avatar: Avatar
  public let facebookConnected: Bool?
  public let id: Int
  public let isFriend: Bool?
  public let liveAuthToken: String?
  public let location: Location?
  public let name: String
  public let newsletters: NewsletterSubscriptions
  public let notifications: Notifications
  public let optedOutOfRecommendations: Bool?
  public let showPublicProfile: Bool?
  public let social: Bool?
  public let stats: Stats

  public struct Avatar {
    public let large: String?
    public let medium: String
    public let small: String
  }

  public struct NewsletterSubscriptions {
    public let arts: Bool?
    public let games: Bool?
    public let happening: Bool?
    public let invent: Bool?
    public let promo: Bool?
    public let weekly: Bool?

    public static func all(on: Bool) -> NewsletterSubscriptions {
      return NewsletterSubscriptions(
        arts: on,
        games: on,
        happening: on,
        invent: on,
        promo: on,
        weekly: on
      )
    }
  }

  public struct Notifications {
    public let backings: Bool?
    public let comments: Bool?
    public let follower: Bool?
    public let friendActivity: Bool?
    public let messages: Bool?
    public let mobileBackings: Bool?
    public let mobileComments: Bool?
    public let mobileFollower: Bool?
    public let mobileFriendActivity: Bool?
    public let mobileMessages: Bool?
    public let mobilePostLikes: Bool?
    public let mobileUpdates: Bool?
    public let postLikes: Bool?
    public let creatorTips: Bool?
    public let updates: Bool?
    public let creatorDigest: Bool?
  }

  public struct Stats {
    public let backedProjectsCount: Int?
    public let createdProjectsCount: Int?
    public let memberProjectsCount: Int?
    public let starredProjectsCount: Int?
    public let unansweredSurveysCount: Int?
    public let unreadMessagesCount: Int?
  }

  public var isCreator: Bool {
    return (self.stats.createdProjectsCount ?? 0) > 0
  }
}

extension User: Equatable {}
public func == (lhs: User, rhs: User) -> Bool {
  return lhs.id == rhs.id
}

extension User: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "User(id: \(id), name: \"\(name)\")"
  }
}

extension User: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<User> {
    let tmp1 = pure(curry(User.init))
      <*> json <| "avatar"
      <*> json <|? "facebook_connected"
      <*> json <| "id"
    let tmp2 = tmp1
      <*> json <|? "is_friend"
      <*> json <|? "ksr_live_token"
      <*> (json <|? "location" <|> .success(nil))
    let tmp3 = tmp2
      <*> json <| "name"
      <*> User.NewsletterSubscriptions.decode(json)
      <*> User.Notifications.decode(json)
      <*> json <|? "opted_out_of_recommendations"
    return tmp3
      <*> json <|? "show_public_profile"
      <*> json <|? "social"
      <*> User.Stats.decode(json)
  }
}

extension User: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["avatar"] = self.avatar.encode()
    result["facebook_connected"] = self.facebookConnected ?? false
    result["id"] = self.id
    result["is_friend"] = self.isFriend ?? false
    result["ksr_live_token"] = self.liveAuthToken
    result["location"] = self.location?.encode()
    result["name"] = self.name
    result["opted_out_of_recommendations"] = self.optedOutOfRecommendations ?? false
    result["show_public_profile"] = self.showPublicProfile ?? false
    result = result.withAllValuesFrom(self.newsletters.encode())
    result = result.withAllValuesFrom(self.notifications.encode())
    result = result.withAllValuesFrom(self.stats.encode())

    return result
  }
}

extension User.Avatar: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<User.Avatar> {
    return curry(User.Avatar.init)
      <^> json <|? "large"
      <*> json <| "medium"
      <*> json <| "small"
  }
}

extension User.Avatar: EncodableType {
  public func encode() -> [String: Any] {
    var ret: [String: Any] = [
      "medium": self.medium,
      "small": self.small
    ]

    ret["large"] = self.large

    return ret
  }
}

extension User.NewsletterSubscriptions: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<User.NewsletterSubscriptions> {
    return curry(User.NewsletterSubscriptions.init)
      <^> json <|? "arts_culture_newsletter"
      <*> json <|? "games_newsletter"
      <*> json <|? "happening_newsletter"
      <*> json <|? "invent_newsletter"
      <*> json <|? "promo_newsletter"
      <*> json <|? "weekly_newsletter"
  }
}

extension User.NewsletterSubscriptions: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["arts_culture_newsletter"] = self.arts
    result["games_newsletter"] = self.games
    result["happening_newsletter"] = self.happening
    result["invent_newsletter"] = self.invent
    result["promo_newsletter"] = self.promo
    result["weekly_newsletter"] = self.weekly
    return result
  }
}

extension User.NewsletterSubscriptions: Equatable {}
public func == (lhs: User.NewsletterSubscriptions, rhs: User.NewsletterSubscriptions) -> Bool {
  return lhs.arts == rhs.arts &&
    lhs.games == rhs.games &&
    lhs.happening == rhs.happening &&
    lhs.invent == rhs.invent &&
    lhs.promo == rhs.promo &&
    lhs.weekly == rhs.weekly
}

extension User.Notifications: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<User.Notifications> {
    let tmp1 = curry(User.Notifications.init)
      <^> json <|? "notify_of_backings"
      <*> json <|? "notify_of_comments"
      <*> json <|? "notify_of_follower"
      <*> json <|? "notify_of_friend_activity"
      <*> json <|? "notify_of_messages"
    let tmp2 = tmp1
      <*> json <|? "notify_mobile_of_backings"
      <*> json <|? "notify_mobile_of_comments"
      <*> json <|? "notify_mobile_of_follower"
      <*> json <|? "notify_mobile_of_friend_activity"
      <*> json <|? "notify_mobile_of_messages"
    return tmp2
      <*> json <|? "notify_mobile_of_post_likes"
      <*> json <|? "notify_mobile_of_updates"
      <*> json <|? "notify_of_post_likes"
      <*> json <|? "notify_of_creator_edu"
      <*> json <|? "notify_of_updates"
      <*> json <|? "notify_of_creator_digest"
  }
}

extension User.Notifications: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["notify_of_backings"] = self.backings
    result["notify_of_comments"] = self.comments
    result["notify_of_follower"] = self.follower
    result["notify_of_friend_activity"] = self.friendActivity
    result["notify_of_messages"] = self.messages
    result["notify_of_post_likes"] = self.postLikes
    result["notify_of_creator_edu"] = self.creatorTips
    result["notify_of_updates"] = self.updates
    result["notify_of_creator_digest"] = self.creatorDigest
    result["notify_mobile_of_backings"] = self.mobileBackings
    result["notify_mobile_of_comments"] = self.mobileComments
    result["notify_mobile_of_follower"] = self.mobileFollower
    result["notify_mobile_of_friend_activity"] = self.mobileFriendActivity
    result["notify_mobile_of_messages"] = self.mobileMessages
    result["notify_mobile_of_post_likes"] = self.mobilePostLikes
    result["notify_mobile_of_updates"] = self.mobileUpdates
    return result
  }
}

extension User.Notifications: Equatable {}
public func == (lhs: User.Notifications, rhs: User.Notifications) -> Bool {
  return lhs.backings == rhs.backings &&
    lhs.comments == rhs.comments &&
    lhs.follower == rhs.follower &&
    lhs.friendActivity == rhs.friendActivity &&
    lhs.messages == rhs.messages &&
    lhs.mobileBackings == rhs.mobileBackings &&
    lhs.mobileComments == rhs.mobileComments &&
    lhs.mobileFollower == rhs.mobileFollower &&
    lhs.mobileFriendActivity == rhs.mobileFriendActivity &&
    lhs.mobileMessages == rhs.mobileMessages &&
    lhs.mobilePostLikes == rhs.mobilePostLikes &&
    lhs.mobileUpdates == rhs.mobileUpdates &&
    lhs.postLikes == rhs.postLikes &&
    lhs.creatorTips == rhs.creatorTips &&
    lhs.updates == rhs.updates &&
    lhs.creatorDigest == rhs.creatorDigest
}

extension User.Stats: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<User.Stats> {
    return curry(User.Stats.init)
      <^> json <|? "backed_projects_count"
      <*> json <|? "created_projects_count"
      <*> json <|? "member_projects_count"
      <*> json <|? "starred_projects_count"
      <*> json <|? "unanswered_surveys_count"
      <*> json <|? "unread_messages_count"
  }
}

extension User.Stats: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["backed_projects_count"] =  self.backedProjectsCount
    result["created_projects_count"] = self.createdProjectsCount
    result["member_projects_count"] = self.memberProjectsCount
    result["starred_projects_count"] = self.starredProjectsCount
    result["unanswered_surveys_count"] = self.unansweredSurveysCount
    result["unread_messages_count"] =  self.unreadMessagesCount
    return result
  }
}
