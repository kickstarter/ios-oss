import Prelude

extension User {
  public enum lens {
    public static let avatar = Lens<User, User.Avatar>(
      view: { $0.avatar },
      set: { User(
        avatar: $0,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social,
        stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let erroredBackingsCount = Lens<User, Int?>(
      view: { $0.erroredBackingsCount },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $0,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social,
        stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let facebookConnected = Lens<User, Bool?>(
      view: { $0.facebookConnected },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $0,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social,
        stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let id = Lens<User, Int>(
      view: { $0.id },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $0,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social, stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let isAdmin = Lens<User, Bool?>(
      view: { $0.isAdmin },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $0,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social, stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let isEmailVerified = Lens<User, Bool?>(
      view: { $0.isEmailVerified },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $0,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social, stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let isFriend = Lens<User, Bool?>(
      view: { $0.isFriend },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $0,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social, stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let isBlocked = Lens<User, Bool>(
      view: { $0.isBlocked },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $0,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social, stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let location = Lens<User, Location?>(
      view: { $0.location },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $0,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social, stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let name = Lens<User, String>(
      view: { $0.name },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $0,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social,
        stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let needsFreshFacebookToken = Lens<User, Bool?>(
      view: { $0.needsFreshFacebookToken },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $0,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social,
        stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let newsletters = Lens<User, User.NewsletterSubscriptions>(
      view: { $0.newsletters },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $0,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social,
        stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let notifications = Lens<User, User.Notifications>(
      view: { $0.notifications },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $0,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social,
        stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let optedOutOfRecommendations = Lens<User, Bool?>(
      view: { $0.optedOutOfRecommendations },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $0,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social,
        stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let ppoHasAction = Lens<User, Bool?>(
      view: { $0.ppoHasAction },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $0,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social,
        stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let showPublicProfile = Lens<User, Bool?>(
      view: { $0.showPublicProfile },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $0,
        social: $1.social,
        stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let social = Lens<User, Bool?>(
      view: { $0.social },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $0,
        stats: $1.stats,
        unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let stats = Lens<User, User.Stats>(
      view: { $0.stats },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social,
        stats: $0, unseenActivityCount: $1.unseenActivityCount
      ) }
    )

    public static let unseenActivityCount = Lens<User, Int?>(
      view: { $0.unseenActivityCount },
      set: { User(
        avatar: $1.avatar,
        erroredBackingsCount: $1.erroredBackingsCount,
        facebookConnected: $1.facebookConnected,
        id: $1.id,
        isAdmin: $1.isAdmin,
        isEmailVerified: $1.isEmailVerified,
        isFriend: $1.isFriend,
        isBlocked: $1.isBlocked,
        location: $1.location,
        name: $1.name,
        needsFreshFacebookToken: $1.needsFreshFacebookToken,
        needsPassword: $1.needsPassword,
        newsletters: $1.newsletters,
        notifications: $1.notifications,
        optedOutOfRecommendations: $1.optedOutOfRecommendations,
        ppoHasAction: $1.ppoHasAction,
        showPublicProfile: $1.showPublicProfile,
        social: $1.social,
        stats: $1.stats, unseenActivityCount: $0
      ) }
    )
  }
}

extension Lens where Whole == User, Part == User.Avatar {
  public var large: Lens<User, String?> {
    return User.lens.avatar .. User.Avatar.lens.large
  }

  public var medium: Lens<User, String> {
    return User.lens.avatar .. User.Avatar.lens.medium
  }

  public var small: Lens<User, String> {
    return User.lens.avatar .. User.Avatar.lens.small
  }
}

extension Lens where Whole == User, Part == User.NewsletterSubscriptions {
  public var arts: Lens<User, Bool?> {
    return User.lens.newsletters .. User.NewsletterSubscriptions.lens.arts
  }

  public var games: Lens<User, Bool?> {
    return User.lens.newsletters .. User.NewsletterSubscriptions.lens.games
  }

  public var happening: Lens<User, Bool?> {
    return User.lens.newsletters .. User.NewsletterSubscriptions.lens.happening
  }

  public var invent: Lens<User, Bool?> {
    return User.lens.newsletters .. User.NewsletterSubscriptions.lens.invent
  }

  public var promo: Lens<User, Bool?> {
    return User.lens.newsletters .. User.NewsletterSubscriptions.lens.promo
  }

  public var weekly: Lens<User, Bool?> {
    return User.lens.newsletters .. User.NewsletterSubscriptions.lens.weekly
  }

  public var films: Lens<User, Bool?> {
    return User.lens.newsletters .. User.NewsletterSubscriptions.lens.films
  }

  public var publishing: Lens<User, Bool?> {
    return User.lens.newsletters .. User.NewsletterSubscriptions.lens.publishing
  }

  public var alumni: Lens<User, Bool?> {
    return User.lens.newsletters .. User.NewsletterSubscriptions.lens.alumni
  }

  public var music: Lens<User, Bool?> {
    return User.lens.newsletters .. User.NewsletterSubscriptions.lens.music
  }
}

extension Lens where Whole == User, Part == User.Notifications {
  public var backings: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.backings
  }

  public var comments: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.comments
  }

  public var follower: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.follower
  }

  public var friendActivity: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.friendActivity
  }

  public var messages: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.messages
  }

  public var postLikes: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.postLikes
  }

  public var creatorTips: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.creatorTips
  }

  public var creatorDigest: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.creatorDigest
  }

  public var updates: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.updates
  }

  public var mobileBackings: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.mobileBackings
  }

  public var mobileComments: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.mobileComments
  }

  public var mobileFollower: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.mobileFollower
  }

  public var mobileFriendActivity: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.mobileFriendActivity
  }

  public var mobileMessages: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.mobileMessages
  }

  public var mobilePostLikes: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.mobilePostLikes
  }

  public var mobileUpdates: Lens<User, Bool?> {
    return User.lens.notifications .. User.Notifications.lens.mobileUpdates
  }
}

extension Lens where Whole == User, Part == User.Stats {
  public var backedProjectsCount: Lens<User, Int?> {
    return User.lens.stats .. User.Stats.lens.backedProjectsCount
  }

  public var createdProjectsCount: Lens<User, Int?> {
    return User.lens.stats .. User.Stats.lens.createdProjectsCount
  }

  public var draftProjectsCount: Lens<User, Int?> {
    return User.lens.stats .. User.Stats.lens.draftProjectsCount
  }

  public var memberProjectsCount: Lens<User, Int?> {
    return User.lens.stats .. User.Stats.lens.memberProjectsCount
  }

  public var starredProjectsCount: Lens<User, Int?> {
    return User.lens.stats .. User.Stats.lens.starredProjectsCount
  }
}
