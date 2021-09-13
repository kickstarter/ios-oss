import Foundation

extension User {
  /**
   Returns a minimal `User` from a `GraphAPI.UserFragment`
   */
  static func user(from userFragment: GraphAPI.UserFragment) -> User? {
    guard let id = decompose(id: userFragment.id) else { return nil }

    let erroredBackingsCount = erroredBackingsCount(userFragment: userFragment)

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
      location: nil,
      name: userFragment.name,
      needsFreshFacebookToken: nil,
      newsletters: NewsletterSubscriptions(),
      notifications: Notifications(),
      optedOutOfRecommendations: nil,
      showPublicProfile: nil,
      social: nil,
      stats: Stats(),
      unseenActivityCount: nil
    )
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
}
