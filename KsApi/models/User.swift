

public struct User {
  public var avatar: Avatar
  public var erroredBackingsCount: Int?
  public var facebookConnected: Bool?
  public var id: Int
  public var isAdmin: Bool?
  public var isEmailVerified: Bool?
  public var isFriend: Bool?
  public var location: Location?
  public var name: String
  public var needsFreshFacebookToken: Bool?
  public var needsPassword: Bool?
  public var newsletters: NewsletterSubscriptions
  public var notifications: Notifications
  public var optedOutOfRecommendations: Bool?
  public var showPublicProfile: Bool?
  public var social: Bool?
  public var stats: Stats
  public var unseenActivityCount: Int?

  public struct Avatar {
    public var large: String?
    public var medium: String
    public var small: String
  }

  public struct NewsletterSubscriptions {
    public var arts: Bool?
    public var games: Bool?
    public var happening: Bool?
    public var invent: Bool?
    public var promo: Bool?
    public var weekly: Bool?
    public var films: Bool?
    public var publishing: Bool?
    public var alumni: Bool?
    public var music: Bool?

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
        alumni: on,
        music: on
      )
    }
  }

  public struct Notifications {
    public var backings: Bool?
    public var commentReplies: Bool?
    public var comments: Bool?
    public var creatorDigest: Bool?
    public var creatorTips: Bool?
    public var follower: Bool?
    public var friendActivity: Bool?
    public var messages: Bool?
    public var mobileBackings: Bool?
    public var mobileComments: Bool?
    public var mobileFollower: Bool?
    public var mobileFriendActivity: Bool?
    public var mobileMarketingUpdate: Bool?
    public var mobileMessages: Bool?
    public var mobilePostLikes: Bool?
    public var mobileUpdates: Bool?
    public var postLikes: Bool?
    public var updates: Bool?
  }

  public struct Stats {
    public var backedProjectsCount: Int?
    public var createdProjectsCount: Int?
    public var draftProjectsCount: Int?
    public var memberProjectsCount: Int?
    public var starredProjectsCount: Int?
    public var unansweredSurveysCount: Int?
    public var unreadMessagesCount: Int?
  }

  public var isCreator: Bool {
    return (self.stats.createdProjectsCount ?? 0) > 0
  }

  public var isRepeatCreator: Bool? {
    guard let createdProjectsCount = self.stats.createdProjectsCount else {
      return nil
    }

    return createdProjectsCount > 1
  }
}

extension User: Equatable {}
public func == (lhs: User, rhs: User) -> Bool {
  return lhs.id == rhs.id
}

extension User: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "User(id: \(self.id), name: \"\(self.name)\")"
  }
}

extension User: Decodable {
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.avatar = try values.decode(Avatar.self, forKey: .avatar)
    self.erroredBackingsCount = try values.decodeIfPresent(Int.self, forKey: .erroredBackingsCount)
    self.facebookConnected = try values.decodeIfPresent(Bool.self, forKey: .facebookConnected)
    self.id = try values.decode(Int.self, forKey: .id)
    self.isAdmin = try values.decodeIfPresent(Bool.self, forKey: .isAdmin)
    self.isEmailVerified = try values.decodeIfPresent(Bool.self, forKey: .isEmailVerified)
    self.isFriend = try values.decodeIfPresent(Bool.self, forKey: .isFriend)
    self.location = try? values.decodeIfPresent(Location.self, forKey: .location)
    self.name = try values.decode(String.self, forKey: .name)
    self.needsFreshFacebookToken = try values.decodeIfPresent(Bool.self, forKey: .needsFreshFacebookToken)
    self.needsPassword = try values.decodeIfPresent(Bool.self, forKey: .needsPassword)
    self.newsletters = try User.NewsletterSubscriptions(from: decoder)
    self.notifications = try User.Notifications(from: decoder)
    self.optedOutOfRecommendations = try values.decodeIfPresent(Bool.self, forKey: .optedOutOfRecommendations)
    self.showPublicProfile = try values.decodeIfPresent(Bool.self, forKey: .showPublicProfile)
    self.social = try values.decodeIfPresent(Bool.self, forKey: .social)
    self.stats = try User.Stats(from: decoder)
    self.unseenActivityCount = try values.decodeIfPresent(Int.self, forKey: .unseenActivityCount)
  }

  enum CodingKeys: String, CodingKey {
    case avatar
    case erroredBackingsCount = "errored_backings_count"
    case facebookConnected = "facebook_connected"
    case id
    case isAdmin = "is_admin"
    case isEmailVerified = "is_email_verified"
    case isFriend = "is_friend"
    case location
    case name
    case needsFreshFacebookToken = "needs_fresh_facebook_token"
    case needsPassword = "needs_password"
    case optedOutOfRecommendations = "opted_out_of_recommendations"
    case showPublicProfile = "show_public_profile"
    case social
    case unseenActivityCount = "unseen_activity_count"
  }
}

extension User: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["avatar"] = self.avatar.encode()
    result["facebook_connected"] = self.facebookConnected ?? false
    result["id"] = self.id
    result["is_admin"] = self.isAdmin ?? false
    result["is_email_verified"] = self.isEmailVerified ?? false
    result["is_friend"] = self.isFriend ?? false
    result["location"] = self.location?.encode()
    result["name"] = self.name
    result["needs_password"] = self.needsPassword ?? false
    result["opted_out_of_recommendations"] = self.optedOutOfRecommendations ?? false
    result["social"] = self.social ?? false
    result["show_public_profile"] = self.showPublicProfile ?? false
    result = result.withAllValuesFrom(self.newsletters.encode())
    result = result.withAllValuesFrom(self.notifications.encode())
    result = result.withAllValuesFrom(self.stats.encode())

    return result
  }
}

extension User.Avatar: Decodable {
  enum CodingKeys: String, CodingKey {
    case large
    case medium
    case small
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

extension User.NewsletterSubscriptions: Decodable {
  enum CodingKeys: String, CodingKey {
    case arts = "arts_culture_newsletter"
    case games = "games_newsletter"
    case happening = "happening_newsletter"
    case invent = "invent_newsletter"
    case promo = "promo_newsletter"
    case weekly = "weekly_newsletter"
    case films = "film_newsletter"
    case publishing = "publishing_newsletter"
    case alumni = "alumni_newsletter"
    case music = "music_newsletter"
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
    result["music_newsletter"] = self.music
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

extension User.Notifications: Decodable {
  enum CodingKeys: String, CodingKey {
    case backings = "notify_of_backings"
    case commentReplies = "notify_of_comment_replies"
    case comments = "notify_of_comments"
    case creatorDigest = "notify_of_creator_digest"
    case creatorTips = "notify_of_creator_edu"
    case follower = "notify_of_follower"
    case friendActivity = "notify_of_friend_activity"
    case messages = "notify_of_messages"
    case mobileBackings = "notify_mobile_of_backings"
    case mobileComments = "notify_mobile_of_comments"
    case mobileFriendActivity = "notify_mobile_of_friend_activity"
    case mobileMarketingUpdate = "notify_mobile_of_marketing_update"
    case mobileMessages = "notify_mobile_of_messages"
    case mobileFollower = "notify_mobile_of_follower"
    case mobilePostLikes = "notify_mobile_of_post_likes"
    case mobileUpdates = "notify_mobile_of_updates"
    case postLikes = "notify_of_post_likes"
    case updates = "notify_of_updates"
  }
}

extension User.Notifications: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["notify_of_backings"] = self.backings
    result["notify_of_comment_replies"] = self.commentReplies
    result["notify_of_comments"] = self.comments
    result["notify_of_creator_digest"] = self.creatorDigest
    result["notify_of_creator_edu"] = self.creatorTips
    result["notify_of_follower"] = self.follower
    result["notify_of_friend_activity"] = self.friendActivity
    result["notify_of_messages"] = self.messages
    result["notify_mobile_of_comments"] = self.mobileComments
    result["notify_mobile_of_follower"] = self.mobileFollower
    result["notify_mobile_of_friend_activity"] = self.mobileFriendActivity
    result["notify_mobile_of_marketing_update"] = self.mobileMarketingUpdate
    result["notify_mobile_of_messages"] = self.mobileMessages
    result["notify_mobile_of_post_likes"] = self.mobilePostLikes
    result["notify_mobile_of_updates"] = self.mobileUpdates
    result["notify_of_post_likes"] = self.postLikes
    result["notify_of_updates"] = self.updates
    result["notify_mobile_of_backings"] = self.mobileBackings
    return result
  }
}

extension User.Notifications: Equatable {}

extension User.Stats: Decodable {
  enum CodingKeys: String, CodingKey {
    case backedProjectsCount = "backed_projects_count"
    case createdProjectsCount = "created_projects_count"
    case draftProjectsCount = "draft_projects_count"
    case memberProjectsCount = "member_projects_count"
    case starredProjectsCount = "starred_projects_count"
    case unansweredSurveysCount = "unanswered_surveys_count"
    case unreadMessagesCount = "unread_messages_count"
  }
}

extension User.Stats: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["backed_projects_count"] = self.backedProjectsCount
    result["created_projects_count"] = self.createdProjectsCount
    result["draft_projects_count"] = self.draftProjectsCount
    result["member_projects_count"] = self.memberProjectsCount
    result["starred_projects_count"] = self.starredProjectsCount
    result["unanswered_surveys_count"] = self.unansweredSurveysCount
    result["unread_messages_count"] = self.unreadMessagesCount
    return result
  }
}
