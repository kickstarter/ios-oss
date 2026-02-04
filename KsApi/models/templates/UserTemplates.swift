import Prelude

extension User {
  internal static let template = User(
    avatar: .template,
    chosenCurrency: nil,
    facebookConnected: nil,
    id: 1,
    isAdmin: false,
    isEmailVerified: false,
    isFriend: nil,
    isBlocked: false,
    location: nil,
    name: "Blob",
    needsFreshFacebookToken: false,
    needsPassword: false,
    newsletters: .template,
    notifications: .template,
    optedOutOfRecommendations: false,
    showPublicProfile: false,
    social: nil,
    stats: .template,
    unseenActivityCount: nil
  )

  internal static let projectCreator = User(
    avatar: Avatar(
      large: "https://i.kickstarter.com/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?fit=crop&height=80&origin=ugc&q=92&width=80&sig=fVf5SA513LFbbFr5PYXBGGzhuW%2FktUYIBG1NxAaA8zg%3D",
      medium: "https://i.kickstarter.com/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?fit=crop&height=80&origin=ugc&q=92&width=80&sig=fVf5SA513LFbbFr5PYXBGGzhuW%2FktUYIBG1NxAaA8zg%3D",
      small: "https://i.kickstarter.com/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?fit=crop&height=80&origin=ugc&q=92&width=80&sig=fVf5SA513LFbbFr5PYXBGGzhuW%2FktUYIBG1NxAaA8zg%3D"
    ),
    chosenCurrency: nil,
    facebookConnected: nil,
    id: "Alma Haser".hash,
    isAdmin: nil,
    isEmailVerified: nil,
    isFriend: nil,
    isBlocked: false,
    location: nil,
    name: "Alma Haser",
    needsFreshFacebookToken: nil,
    needsPassword: nil,
    newsletters: User.NewsletterSubscriptions(),
    notifications: User.Notifications(),
    optedOutOfRecommendations: nil,
    showPublicProfile: false,
    social: nil,
    stats: User.Stats(),
    unseenActivityCount: nil
  )

  internal static let backer = User(
    avatar: Avatar(
      large: "https://i.kickstarter.com/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?fit=crop&height=80&origin=ugc&q=92&width=80&sig=fVf5SA513LFbbFr5PYXBGGzhuW%2FktUYIBG1NxAaA8zg%3D",
      medium: "https://i.kickstarter.com/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?fit=crop&height=80&origin=ugc&q=92&width=80&sig=fVf5SA513LFbbFr5PYXBGGzhuW%2FktUYIBG1NxAaA8zg%3D",
      small: "https://i.kickstarter.com/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?fit=crop&height=80&origin=ugc&q=92&width=80&sig=fVf5SA513LFbbFr5PYXBGGzhuW%2FktUYIBG1NxAaA8zg%3D"
    ),
    chosenCurrency: nil,
    facebookConnected: nil,
    id: "Backer".hash,
    isAdmin: nil,
    isEmailVerified: nil,
    isFriend: nil,
    isBlocked: false,
    location: nil,
    name: "Backer",
    needsFreshFacebookToken: nil,
    needsPassword: nil,
    newsletters: User.NewsletterSubscriptions(),
    notifications: User.Notifications(),
    optedOutOfRecommendations: nil,
    showPublicProfile: false,
    social: nil,
    stats: User.Stats(),
    unseenActivityCount: nil
  )

  // swiftformat:disable wrap
  internal static let brando = User.template
    |> \.avatar.large .~ "https://i.kickstarter.com/assets/006/258/518/b9033f46095b83119188cf9a66d19356_original.jpg?fit=crop&height=160&origin=ugc&q=92&width=160&sig=DXAnyfMrnKL%2F6k3oAaqRRpeq5hfWTa%2FNnp%2BpPIrvPK4%3D"
    |> \.avatar.medium .~ "https://i.kickstarter.com/assets/006/258/518/b9033f46095b83119188cf9a66d19356_original.jpg?fit=crop&height=40&origin=ugc&q=92&width=40&sig=mBRN3jxnh3zAaK6%2BBAoQJjbmi5XK7Bxu5MJf71R41Ho%3D"
    |> \.avatar.small .~ "https://i.kickstarter.com/assets/006/258/518/b9033f46095b83119188cf9a66d19356_original.jpg?fit=crop&height=40&origin=ugc&q=92&width=40&sig=mBRN3jxnh3zAaK6%2BBAoQJjbmi5XK7Bxu5MJf71R41Ho%3D"
    |> \.id .~ "brando".hash
    |> \.name .~ "Brandon Williams"
  // swiftformat:enable wrap
}
