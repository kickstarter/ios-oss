// swiftlint:disable line_length
import Prelude

extension User {
  internal static let template = User(
    avatar: .template,
    facebookConnected: nil,
    id: 1,
    isFriend: nil,
    liveAuthToken: "deadbeef",
    location: nil,
    name: "Blob",
    newsletters: .template,
    notifications: .template,
    optedOutOfRecommendations: false,
    showPublicProfile: false,
    social: nil,
    stats: .template
  )

  internal static let brando = .template
    |> User.lens.avatar.large .~ "https://ksr-ugc.imgix.net/assets/006/258/518/b9033f46095b83119188cf9a66d19356_original.jpg?w=160&h=160&fit=crop&v=1461376829&auto=format&q=92&s=8d7666f01ab6765c3cf09149751ff077"
    |> User.lens.avatar.medium .~ "https://ksr-ugc.imgix.net/assets/006/258/518/b9033f46095b83119188cf9a66d19356_original.jpg?w=40&h=40&fit=crop&v=1461376829&auto=format&q=92&s=0fcedf8888ca6990408ccde81888899b"
    |> User.lens.avatar.small .~ "https://ksr-ugc.imgix.net/assets/006/258/518/b9033f46095b83119188cf9a66d19356_original.jpg?w=40&h=40&fit=crop&v=1461376829&auto=format&q=92&s=0fcedf8888ca6990408ccde81888899b"
    |> User.lens.id .~ "brando".hash
    |> User.lens.name .~ "Brandon Williams"
}
