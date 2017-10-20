import Prelude

extension User.Notifications {
  public enum lens {
    public static let backings = Lens<User.Notifications, Bool?>(
      view: { $0.backings },
      set: { User.Notifications(backings: $0, comments: $1.comments, follower: $1.follower,
        friendActivity: $1.friendActivity, mobileBackings: $1.mobileBackings,
        mobileComments: $1.mobileComments, mobileFollower: $1.mobileFollower,
        mobileFriendActivity: $1.mobileFriendActivity, mobilePostLikes: $1.mobilePostLikes,
        mobileUpdates: $1.mobileUpdates, postLikes: $1.postLikes, updates: $1.updates) }
    )

    public static let comments = Lens<User.Notifications, Bool?>(
      view: { $0.comments },
      set: { User.Notifications(backings: $1.backings, comments: $0, follower: $1.follower,
        friendActivity: $1.friendActivity,
        mobileBackings: $1.mobileBackings, mobileComments: $1.mobileComments,
        mobileFollower: $1.mobileFollower, mobileFriendActivity: $1.mobileFriendActivity,
        mobilePostLikes: $1.mobilePostLikes, mobileUpdates: $1.mobileUpdates,
        postLikes: $1.postLikes, updates: $1.updates) }
    )

    public static let follower = Lens<User.Notifications, Bool?>(
      view: { $0.follower },
      set: { User.Notifications(backings: $1.backings, comments: $1.comments, follower: $0,
        friendActivity: $1.friendActivity,
        mobileBackings: $1.mobileBackings, mobileComments: $1.mobileComments,
        mobileFollower: $1.mobileFollower, mobileFriendActivity: $1.mobileFriendActivity,
        mobilePostLikes: $1.mobilePostLikes, mobileUpdates: $1.mobileUpdates,
        postLikes: $1.postLikes, updates: $1.updates) }
    )

    public static let friendActivity = Lens<User.Notifications, Bool?>(
      view: { $0.friendActivity },
      set: { User.Notifications(backings: $1.backings, comments: $1.comments, follower: $1.follower,
        friendActivity: $0, mobileBackings: $1.mobileBackings, mobileComments: $1.mobileComments,
        mobileFollower: $1.mobileFollower, mobileFriendActivity: $1.mobileFriendActivity,
        mobilePostLikes: $1.mobilePostLikes, mobileUpdates: $1.mobileUpdates, postLikes: $1.postLikes,
        updates: $1.updates) }
    )

    public static let postLikes = Lens<User.Notifications, Bool?>(
      view: { $0.postLikes },
      set: { User.Notifications(backings: $1.backings, comments: $1.comments, follower: $1.follower,
        friendActivity: $1.friendActivity, mobileBackings: $1.mobileBackings,
        mobileComments: $1.mobileComments, mobileFollower: $1.mobileFollower,
        mobileFriendActivity: $1.mobileFriendActivity, mobilePostLikes: $1.mobilePostLikes,
        mobileUpdates: $1.mobileUpdates, postLikes: $0, updates: $1.updates) }
    )

    public static let updates = Lens<User.Notifications, Bool?>(
      view: { $0.updates },
      set: { User.Notifications(backings: $1.backings, comments: $1.comments, follower: $1.follower,
        friendActivity: $1.friendActivity, mobileBackings: $1.mobileBackings,
        mobileComments: $1.mobileComments, mobileFollower: $1.mobileFollower,
        mobileFriendActivity: $1.mobileFriendActivity, mobilePostLikes: $1.mobilePostLikes,
        mobileUpdates: $1.mobileUpdates, postLikes: $1.postLikes, updates: $0) }
    )

    public static let mobileBackings = Lens<User.Notifications, Bool?>(
      view: { $0.mobileBackings },
      set: { User.Notifications(backings: $1.backings, comments: $1.comments, follower: $1.follower,
        friendActivity: $1.friendActivity, mobileBackings: $0, mobileComments: $1.mobileComments,
        mobileFollower: $1.mobileFollower, mobileFriendActivity: $1.mobileFriendActivity,
        mobilePostLikes: $1.mobilePostLikes, mobileUpdates: $1.mobileUpdates, postLikes: $1.postLikes,
        updates: $1.updates) }
    )

    public static let mobileComments = Lens<User.Notifications, Bool?>(
      view: { $0.mobileComments },
      set: { User.Notifications(backings: $1.backings, comments: $1.comments, follower: $1.follower,
        friendActivity: $1.friendActivity, mobileBackings: $1.mobileBackings, mobileComments: $0,
        mobileFollower: $1.mobileFollower, mobileFriendActivity: $1.mobileFriendActivity,
        mobilePostLikes: $1.mobilePostLikes, mobileUpdates: $1.mobileUpdates, postLikes: $1.postLikes,
        updates: $1.updates) }
    )

    public static let mobileFollower = Lens<User.Notifications, Bool?>(
      view: { $0.mobileFollower },
      set: { User.Notifications(backings: $1.backings, comments: $1.comments, follower: $1.follower,
        friendActivity: $1.friendActivity, mobileBackings: $1.mobileBackings,
        mobileComments: $1.mobileComments, mobileFollower: $0, mobileFriendActivity: $1.mobileFriendActivity,
        mobilePostLikes: $1.mobilePostLikes, mobileUpdates: $1.mobileUpdates, postLikes: $1.postLikes,
        updates: $1.updates) }
    )

    public static let mobileFriendActivity = Lens<User.Notifications, Bool?>(
      view: { $0.mobileFriendActivity },
      set: { User.Notifications(backings: $1.backings, comments: $1.comments, follower: $1.follower,
        friendActivity: $1.friendActivity, mobileBackings: $1.mobileBackings,
        mobileComments: $1.mobileComments, mobileFollower: $1.mobileFollower, mobileFriendActivity: $0,
        mobilePostLikes: $1.mobilePostLikes, mobileUpdates: $1.mobileUpdates, postLikes: $1.postLikes,
        updates: $1.updates) }
    )

    public static let mobilePostLikes = Lens<User.Notifications, Bool?>(
      view: { $0.mobilePostLikes },
      set: { User.Notifications(backings: $1.backings, comments: $1.comments, follower: $1.follower,
        friendActivity: $1.friendActivity, mobileBackings: $1.mobileBackings,
        mobileComments: $1.mobileComments, mobileFollower: $1.mobileFollower,
        mobileFriendActivity: $1.mobileFriendActivity, mobilePostLikes: $0, mobileUpdates: $1.mobileUpdates,
        postLikes: $1.postLikes, updates: $1.updates) }
    )

    public static let mobileUpdates = Lens<User.Notifications, Bool?>(
      view: { $0.mobileUpdates },
      set: { User.Notifications(backings: $1.backings, comments: $1.comments, follower: $1.follower,
        friendActivity: $1.friendActivity, mobileBackings: $1.mobileBackings,
        mobileComments: $1.mobileComments, mobileFollower: $1.mobileFollower,
        mobileFriendActivity: $1.mobileFriendActivity, mobilePostLikes: $1.mobilePostLikes,
        mobileUpdates: $0, postLikes: $1.postLikes, updates: $1.updates) }
    )
  }
}
