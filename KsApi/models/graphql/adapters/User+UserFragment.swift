import Foundation

extension User {
  /**
   Returns a minimal `User` from a `GraphAPI.UserFragment`
   */
  static func user(from userFragment: GraphAPI.UserFragment) -> User? {
    guard let id = decompose(id: userFragment.id) else { return nil }

    let erroredBackingsCount = erroredBackingsCount(userFragment: userFragment)

    /// Not accurate, but GQL doesn't currently return an unseen activity count as a top-level property on the `UserFragment`
    let unseenUserActivityCount = userFragment.hasUnseenActivity != nil ? 1 : 0

    return User(
      avatar: Avatar(
        large: userFragment.imageUrl,
        medium: userFragment.imageUrl,
        small: userFragment.imageUrl
      ),
      erroredBackingsCount: erroredBackingsCount == 0 ? nil : erroredBackingsCount,
      facebookConnected: self.isFacebookConnected(userFragment: userFragment),
      id: id,
      isAdmin: self.isAdmin(userFragment: userFragment),
      isEmailVerified: self.isEmailVerified(userFragment: userFragment),
      isFriend: userFragment.isFollowing,
      location: self.location(userFragment: userFragment),
      name: userFragment.name,
      needsFreshFacebookToken: userFragment.needsFreshFacebookToken,
      needsPassword: self.needsPassword(userFragment: userFragment),
      newsletters: self.newsletterSubscriptions(userFragment: userFragment),
      notifications: self.notifications(userFragment: userFragment),
      optedOutOfRecommendations: userFragment.optedOutOfRecommendations,
      showPublicProfile: userFragment.showPublicProfile,
      social: userFragment.isSocializing,
      stats: self.userStats(userFragment: userFragment),
      unseenActivityCount: unseenUserActivityCount
    )
  }

  private static func newsletterSubscriptions(userFragment: GraphAPI
    .UserFragment) -> NewsletterSubscriptions {
    let newslettersSubscriptions = NewsletterSubscriptions(
      arts: userFragment.newsletterSubscriptions?
        .artsCultureNewsletter,
      games: userFragment.newsletterSubscriptions?
        .gamesNewsletter,
      happening: userFragment.newsletterSubscriptions?
        .happeningNewsletter,
      invent: userFragment.newsletterSubscriptions?
        .inventNewsletter,
      promo: userFragment.newsletterSubscriptions?
        .promoNewsletter,
      weekly: userFragment.newsletterSubscriptions?
        .weeklyNewsletter,
      films: userFragment.newsletterSubscriptions?
        .filmNewsletter,
      publishing: userFragment.newsletterSubscriptions?
        .publishingNewsletter,
      alumni: userFragment.newsletterSubscriptions?
        .alumniNewsletter,
      music: userFragment.newsletterSubscriptions?
        .musicNewsletter
    )

    return newslettersSubscriptions
  }

  private static func notifications(userFragment: GraphAPI
    .UserFragment) -> Notifications {
    guard let userNotifications = userFragment.notifications else {
      return Notifications()
    }

    var backingsNotification: Bool?
    var commentRepliesNotification: Bool?
    var commentsNotification: Bool?
    var creatorDigestNotification: Bool?
    var creatorTipsNotification: Bool?
    var followerNotification: Bool?
    var friendActivityNotification: Bool?
    var messagesNotification: Bool?
    var postLikesNotification: Bool?
    var updatesNotification: Bool?
    var mobileBackingsNotification: Bool?
    var mobileCommentsNotification: Bool?
    var mobileFollowerNotification: Bool?
    var mobileFriendActivityNotification: Bool?
    var mobileMarketingUpdateNotification: Bool?
    var mobileMessagesNotification: Bool?
    var mobilePostLikesNotification: Bool?
    var mobileUpdatesNotification: Bool?

    for notification in userNotifications {
      switch (notification.topic, notification.mobile, notification.email) {
      case let (.backings, mobileEnabled, emailEnabled):
        backingsNotification = emailEnabled
        mobileBackingsNotification = mobileEnabled
      case let (.commentReplies, _, emailEnabled):
        commentRepliesNotification = emailEnabled
      case let (.comments, mobileEnabled, emailEnabled):
        commentsNotification = emailEnabled
        mobileCommentsNotification = mobileEnabled
      case let (.creatorDigest, _, emailEnabled):
        creatorDigestNotification = emailEnabled
      case let (.creatorEdu, _, emailEnabled):
        creatorTipsNotification = emailEnabled
      case let (.follower, mobileEnabled, emailEnabled):
        followerNotification = emailEnabled
        mobileFollowerNotification = mobileEnabled
      case let (.friendActivity, mobileEnabled, emailEnabled):
        friendActivityNotification = emailEnabled
        mobileFriendActivityNotification = mobileEnabled
      case let (.messages, mobileEnabled, emailEnabled):
        messagesNotification = emailEnabled
        mobileMessagesNotification = mobileEnabled
      /** FIXME: No longer supported by GQL Schema.
       case let (.postLikes, mobileEnabled, emailEnabled):
         postLikesNotification = emailEnabled
         mobilePostLikesNotification = mobileEnabled
       */
      case let (.updates, mobileEnabled, emailEnabled):
        updatesNotification = emailEnabled
        mobileUpdatesNotification = mobileEnabled
      case let (.marketingUpdate, mobileEnabled, _):
        mobileMarketingUpdateNotification = mobileEnabled
      default:
        continue
      }
    }

    let notifications = Notifications(
      backings: backingsNotification,
      commentReplies: commentRepliesNotification,
      comments: commentsNotification,
      creatorDigest: creatorDigestNotification,
      creatorTips: creatorTipsNotification,
      follower: followerNotification,
      friendActivity: friendActivityNotification,
      messages: messagesNotification,
      mobileBackings: mobileBackingsNotification,
      mobileComments: mobileCommentsNotification,
      mobileFollower: mobileFollowerNotification,
      mobileFriendActivity: mobileFriendActivityNotification,
      mobileMarketingUpdate: mobileMarketingUpdateNotification,
      mobileMessages: mobileMessagesNotification,
      mobilePostLikes: mobilePostLikesNotification,
      mobileUpdates: nil,
      postLikes: nil,
      updates: updatesNotification
    )

    return notifications
  }

  private static func userStats(userFragment: GraphAPI.UserFragment) -> Stats {
    let backedProjectsCount = userFragment.backingsCount
    let createdProjectsCount = userFragment.createdProjects?.totalCount
    let draftProjectsCount: Int? = nil /// Unavailable on GQL at this time.
    let starredProjectsCount = userFragment.savedProjects?.totalCount
    /** FIXME:
     Adding this to the `UserFragment` causes an issue with the query because user has to be logged in. However we use the `UserFragment` on loading a project page, so we need that query `FetchProjectQueryById` and `FetchProjectQueryBySlug` to not error, because the user needs the data regardless of their session state.

     This fragment can be added back into `UserFragment` once we come up with a new GQL model for our Project Page:
     ```
     membershipProjects {
       totalCount
     }
     ```
     */
    let memberProjectsCount: Int? =
      nil // TODO: Once above FIXME is resolved use `userFragment.membershipProjects?.totalCount` here.
    let hasUnreadMessages = userFragment.hasUnreadMessages ?? false
    let unreadMessagesCount: Int = hasUnreadMessages ? 1 : 0
    let unansweredSurveysCount = userFragment.surveyResponses?.totalCount

    let userStats = Stats(
      backedProjectsCount: backedProjectsCount,
      createdProjectsCount: createdProjectsCount,
      draftProjectsCount: draftProjectsCount,
      memberProjectsCount: memberProjectsCount,
      starredProjectsCount: starredProjectsCount,
      unansweredSurveysCount: unansweredSurveysCount,
      unreadMessagesCount: unreadMessagesCount
    )

    return userStats
  }

  private static func erroredBackingsCount(userFragment: GraphAPI.UserFragment) -> Int {
    var erroredBackingsCount = 0

    if let erroredBackings = userFragment.backings?.nodes {
      erroredBackingsCount = erroredBackings.reduce(0) { accum, backing in

        var increment = false

        if backing?.errorReason != nil {
          increment = true
        }

        return increment ? accum + 1 : accum
      }
    }

    return erroredBackingsCount
  }

  private static func isFacebookConnected(userFragment: GraphAPI.UserFragment) -> Bool? {
    var isFacebookConnected: Bool?

    if let facebookConnected = userFragment.isFacebookConnected {
      isFacebookConnected = facebookConnected
    }

    return isFacebookConnected
  }

  private static func needsPassword(userFragment: GraphAPI.UserFragment) -> Bool {
    guard let userHasPassword = userFragment.hasPassword else {
      return true
    }

    return !userHasPassword
  }

  private static func isAdmin(userFragment: GraphAPI.UserFragment) -> Bool? {
    var isAdmin: Bool?

    if let ksrAdmin = userFragment.isKsrAdmin {
      isAdmin = ksrAdmin
    }

    return isAdmin
  }

  private static func isEmailVerified(userFragment: GraphAPI.UserFragment) -> Bool? {
    var isEmailVerified: Bool?

    if let emailVerified = userFragment.isEmailVerified {
      isEmailVerified = emailVerified
    }

    return isEmailVerified
  }

  private static func location(userFragment: GraphAPI.UserFragment) -> Location? {
    guard let locationFragment = userFragment.location?.fragments.locationFragment else {
      return nil
    }

    return Location.location(from: locationFragment)
  }
}
