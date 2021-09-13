import Foundation

extension User {
  /**
   Returns a minimal `User` from a `GraphAPI.UserFragment`
   */
  static func user(from userFragment: GraphAPI.UserFragment) -> User? {
    guard let id = decompose(id: userFragment.id) else { return nil }

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
    
    var isFacebookConnected: Bool?
    
    if let facebookConnected = userFragment.isFacebookConnected {
      isFacebookConnected = facebookConnected
    }
    
    var isAdmin: Bool?
    
    if let ksrAdmin = userFragment.isKsrAdmin {
      isAdmin = ksrAdmin
    }
    
    var isEmailVerified: Bool?
    
    if let emailVerified = userFragment.isEmailVerified {
      isEmailVerified = emailVerified
    }

    return User(
      avatar: Avatar(
        large: userFragment.imageUrl,
        medium: userFragment.imageUrl,
        small: userFragment.imageUrl
      ),
      erroredBackingsCount: erroredBackingsCount == 0 ? nil : erroredBackingsCount,
      facebookConnected: isFacebookConnected,
      id: id,
      isAdmin: isAdmin,
      isEmailVerified: isEmailVerified,
      isFriend: nil,
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
}
