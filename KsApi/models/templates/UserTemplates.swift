import Prelude

extension User {
  internal static let template = User(
    avatar: .template,
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

  // swiftformat:disable wrap
  internal static let brando = User.template
    |> \.avatar.large .~ "https://i.kickstarter.com/assets/006/258/518/b9033f46095b83119188cf9a66d19356_original.jpg?fit=crop&height=160&origin=ugc&q=92&width=160&sig=DXAnyfMrnKL%2F6k3oAaqRRpeq5hfWTa%2FNnp%2BpPIrvPK4%3D"
    |> \.avatar.medium .~ "https://i.kickstarter.com/assets/006/258/518/b9033f46095b83119188cf9a66d19356_original.jpg?fit=crop&height=40&origin=ugc&q=92&width=40&sig=mBRN3jxnh3zAaK6%2BBAoQJjbmi5XK7Bxu5MJf71R41Ho%3D"
    |> \.avatar.small .~ "https://i.kickstarter.com/assets/006/258/518/b9033f46095b83119188cf9a66d19356_original.jpg?fit=crop&height=40&origin=ugc&q=92&width=40&sig=mBRN3jxnh3zAaK6%2BBAoQJjbmi5XK7Bxu5MJf71R41Ho%3D"
    |> \.id .~ "brando".hash
    |> \.name .~ "Brandon Williams"
  // swiftformat:enable wrap
}
