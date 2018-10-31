import Argo
import Curry
import Runes

public struct User {
  public private(set) var avatar: Avatar
  public private(set) var facebookConnected: Bool?
  public private(set) var id: Int
  public private(set) var isFriend: Bool?
  public private(set) var liveAuthToken: String?
  public private(set) var location: Location?
  public private(set) var name: String
  public private(set) var needsFreshFacebookToken: Bool?
  public private(set) var newsletters: NewsletterSubscriptions
  public private(set) var notifications: Notifications
  public private(set) var optedOutOfRecommendations: Bool?
  public private(set) var showPublicProfile: Bool?
  public private(set) var social: Bool?
  public private(set) var stats: Stats

  public struct Avatar {
    public private(set) var large: String?
    public private(set) var medium: String
    public private(set) var small: String
  }

  public struct NewsletterSubscriptions {
    public private(set) var arts: Bool?
    public private(set) var games: Bool?
    public private(set) var happening: Bool?
    public private(set) var invent: Bool?
    public private(set) var promo: Bool?
    public private(set) var weekly: Bool?
    public private(set) var films: Bool?
    public private(set) var publishing: Bool?
    public private(set) var alumni: Bool?

    public static func all(on: Bool) -> NewsletterSubscriptions {
      return NewsletterSubscriptions(
        arts: on,
        games: on,
        happening: on,
        invent: on,
        promo: on,
        weekly: on,
        films: on,
        publishing: on,
        alumni: on
      )
    }
  }

  public struct Notifications {
    public private(set) var backings: Bool?
    public private(set) var comments: Bool?
    public private(set) var follower: Bool?
    public private(set) var friendActivity: Bool?
    public private(set) var messages: Bool?
    public private(set) var mobileBackings: Bool?
    public private(set) var mobileComments: Bool?
    public private(set) var mobileFollower: Bool?
    public private(set) var mobileFriendActivity: Bool?
    public private(set) var mobileMessages: Bool?
    public private(set) var mobilePostLikes: Bool?
    public private(set) var mobileUpdates: Bool?
    public private(set) var postLikes: Bool?
    public private(set) var creatorTips: Bool?
    public private(set) var updates: Bool?
    public private(set) var creatorDigest: Bool?
  }

  public struct Stats {
    public private(set) var backedProjectsCount: Int?
    public private(set) var createdProjectsCount: Int?
    public private(set) var memberProjectsCount: Int?
    public private(set) var starredProjectsCount: Int?
    public private(set) var unansweredSurveysCount: Int?
    public private(set) var unreadMessagesCount: Int?
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
      <*> json <|? "needs_fresh_facebook_token"
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
    result["social"] = self.social ?? false
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
      <*> json <|? "film_newsletter"
      <*> json <|? "publishing_newsletter"
      <*> json <|? "alumni_newsletter"
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
    result["film_newsletter"] = self.films
    result["publishing_newsletter"] = self.publishing
    result["alumni_newsletter"] = self.alumni
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
    lhs.weekly == rhs.weekly &&
    lhs.films == rhs.films &&
    lhs.publishing == rhs.publishing &&
    lhs.alumni == rhs.alumni
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
