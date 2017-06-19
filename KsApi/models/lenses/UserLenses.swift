import Prelude

extension User {
  public enum lens {
    public static let avatar = Lens<User, User.Avatar>(
      view: { $0.avatar },
      set: { User(avatar: $0, facebookConnected: $1.facebookConnected, id: $1.id, isFriend: $1.isFriend,
        liveAuthToken: $1.liveAuthToken, location: $1.location, name: $1.name, newsletters: $1.newsletters,
        notifications: $1.notifications, social: $1.social, stats: $1.stats) }
    )

    public static let facebookConnected = Lens<User, Bool?>(
      view: { $0.facebookConnected },
      set: { User(avatar: $1.avatar, facebookConnected: $0, id: $1.id, isFriend: $1.isFriend,
        liveAuthToken: $1.liveAuthToken, location: $1.location, name: $1.name, newsletters: $1.newsletters,
        notifications: $1.notifications, social: $1.social, stats: $1.stats) }
    )

    public static let id = Lens<User, Int>(
      view: { $0.id },
      set: { User(avatar: $1.avatar, facebookConnected: $1.facebookConnected, id: $0, isFriend: $1.isFriend,
        liveAuthToken: $1.liveAuthToken, location: $1.location, name: $1.name, newsletters: $1.newsletters,
        notifications: $1.notifications, social: $1.social, stats: $1.stats) }
    )

    public static let isFriend = Lens<User, Bool?>(
      view: { $0.isFriend },
      set: { User(avatar: $1.avatar, facebookConnected: $1.facebookConnected, id: $1.id, isFriend: $0,
        liveAuthToken: $1.liveAuthToken, location: $1.location, name: $1.name, newsletters: $1.newsletters,
        notifications: $1.notifications, social: $1.social, stats: $1.stats) }
    )

    public static let liveAuthToken = Lens<User, String?>(
      view: { $0.liveAuthToken },
      set: { User(avatar: $1.avatar, facebookConnected: $1.facebookConnected, id: $1.id,
        isFriend: $1.isFriend, liveAuthToken: $0, location: $1.location, name: $1.name,
        newsletters: $1.newsletters, notifications: $1.notifications, social: $1.social, stats: $1.stats) }
    )

    public static let location = Lens<User, Location?>(
      view: { $0.location },
      set: { User(avatar: $1.avatar, facebookConnected: $1.facebookConnected, id: $1.id,
        isFriend: $1.isFriend, liveAuthToken: $1.liveAuthToken, location: $0, name: $1.name,
        newsletters: $1.newsletters, notifications: $1.notifications, social: $1.social, stats: $1.stats) }
    )

    public static let name = Lens<User, String>(
      view: { $0.name },
      set: { User(avatar: $1.avatar, facebookConnected: $1.facebookConnected, id: $1.id,
        isFriend: $1.isFriend, liveAuthToken: $1.liveAuthToken, location: $1.location, name: $0,
        newsletters: $1.newsletters, notifications: $1.notifications, social: $1.social, stats: $1.stats) }
    )

    public static let newsletters = Lens<User, User.NewsletterSubscriptions>(
      view: { $0.newsletters },
      set: { User(avatar: $1.avatar, facebookConnected: $1.facebookConnected, id: $1.id,
        isFriend: $1.isFriend, liveAuthToken: $1.liveAuthToken, location: $1.location, name: $1.name,
        newsletters: $0, notifications: $1.notifications, social: $1.social, stats: $1.stats) }
    )

    public static let notifications = Lens<User, User.Notifications>(
      view: { $0.notifications },
      set: { User(avatar: $1.avatar, facebookConnected: $1.facebookConnected, id: $1.id,
        isFriend: $1.isFriend, liveAuthToken: $1.liveAuthToken, location: $1.location, name: $1.name,
        newsletters: $1.newsletters, notifications: $0, social: $1.social, stats: $1.stats) }
    )

    public static let social = Lens<User, Bool?>(
      view: { $0.social },
      set: { User(avatar: $1.avatar, facebookConnected: $1.facebookConnected, id: $1.id,
        isFriend: $1.isFriend, liveAuthToken: $1.liveAuthToken, location: $1.location, name: $1.name,
        newsletters: $1.newsletters, notifications: $1.notifications, social: $0, stats: $1.stats) }
    )

    public static let stats = Lens<User, User.Stats>(
      view: { $0.stats },
      set: { User(avatar: $1.avatar, facebookConnected: $1.facebookConnected, id: $1.id,
        isFriend: $1.isFriend, liveAuthToken: $1.liveAuthToken, location: $1.location, name: $1.name,
        newsletters: $1.newsletters, notifications: $1.notifications, social: $1.social, stats: $0) }
    )
  }
}

extension Lens where Whole == User, Part == User.Avatar {
  public var large: Lens<User, String?> {
    return User.lens.avatar..User.Avatar.lens.large
  }

  public var medium: Lens<User, String> {
    return User.lens.avatar..User.Avatar.lens.medium
  }

  public var small: Lens<User, String> {
    return User.lens.avatar..User.Avatar.lens.small
  }
}

extension Lens where Whole == User, Part == User.NewsletterSubscriptions {
  public var games: Lens<User, Bool?> {
    return User.lens.newsletters..User.NewsletterSubscriptions.lens.games
  }

  public var happening: Lens<User, Bool?> {
    return User.lens.newsletters..User.NewsletterSubscriptions.lens.happening
  }

  public var promo: Lens<User, Bool?> {
    return User.lens.newsletters..User.NewsletterSubscriptions.lens.promo
  }

  public var weekly: Lens<User, Bool?> {
    return User.lens.newsletters..User.NewsletterSubscriptions.lens.weekly
  }
}

extension Lens where Whole == User, Part == User.Notifications {
  public var backings: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.backings
  }

  public var comments: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.comments
  }

  public var follower: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.follower
  }

  public var friendActivity: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.friendActivity
  }

  public var postLikes: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.postLikes
  }

  public var updates: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.updates
  }

  public var mobileBackings: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.mobileBackings
  }

  public var mobileComments: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.mobileComments
  }

  public var mobileFollower: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.mobileFollower
  }

  public var mobileFriendActivity: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.mobileFriendActivity
  }

  public var mobilePostLikes: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.mobilePostLikes
  }

  public var mobileUpdates: Lens<User, Bool?> {
    return User.lens.notifications..User.Notifications.lens.mobileUpdates
  }
}

extension Lens where Whole == User, Part == User.Stats {
  public var backedProjectsCount: Lens<User, Int?> {
    return User.lens.stats..User.Stats.lens.backedProjectsCount
  }

  public var createdProjectsCount: Lens<User, Int?> {
    return User.lens.stats..User.Stats.lens.createdProjectsCount
  }

  public var memberProjectsCount: Lens<User, Int?> {
    return User.lens.stats..User.Stats.lens.memberProjectsCount
  }

  public var starredProjectsCount: Lens<User, Int?> {
    return User.lens.stats..User.Stats.lens.starredProjectsCount
  }
}
