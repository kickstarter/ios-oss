import Foundation

extension User {
  /**
   Returns a minimal `User` from a `GraphUser`
   */
  static func user(from graphUser: GraphUser) -> User? {
    guard let id = decompose(id: graphUser.id) else { return nil }

    return User(
      avatar: Avatar(
        large: graphUser.imageUrl,
        medium: graphUser.imageUrl,
        small: graphUser.imageUrl
      ),
      erroredBackingsCount: nil,
      facebookConnected: nil,
      id: id,
      isAdmin: nil,
      isEmailVerified: nil,
      isFriend: nil,
      location: nil,
      name: graphUser.name,
      needsFreshFacebookToken: nil,
      needsPassword: false,
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
