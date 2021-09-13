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

    return User(
      avatar: Avatar(
        large: userFragment.imageUrl,
        medium: userFragment.imageUrl,
        small: userFragment.imageUrl
      ),
      erroredBackingsCount: erroredBackingsCount == 0 ? nil : erroredBackingsCount,
      facebookConnected: nil,
      id: id,
      isAdmin: nil,
      isEmailVerified: nil,
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
