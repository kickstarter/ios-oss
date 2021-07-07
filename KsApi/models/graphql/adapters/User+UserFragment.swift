import Foundation

extension User {
  /**
   Returns a minimal `User` from a `GraphUser`
   */
  // TODO: Add test
  static func user(from userFragment: GraphAPI.UserFragment) -> User? {
    guard let id = decompose(id: userFragment.id) else { return nil }

    return User(
      avatar: Avatar(
        large: userFragment.imageUrl,
        medium: userFragment.imageUrl,
        small: userFragment.imageUrl
      ),
      erroredBackingsCount: nil,
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
