import Prelude

// swiftlint:disable line_length
extension Project {
  internal static let template = Project(
    blurb: "A fun project.",
    category: .template,
    country: .us,
    creator: .template |> User.lens.stats.createdProjectsCount .~ 1,
    memberData: Project.MemberData(
      lastUpdatePublishedAt: nil,
      permissions: [],
      unreadMessagesCount: nil,
      unseenActivityCount: nil
    ),
    dates: Project.Dates(
      deadline: Date(timeIntervalSince1970: 1475361315).timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 15.0,
      featuredAt: nil,
      launchedAt: Date(timeIntervalSince1970: 1475361315).timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 15.0,
      potdAt: nil,
      stateChangedAt: Date(
        timeIntervalSince1970: 1475361315).timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 15.0
    ),
    id: 1,
    location: .template,
    name: "The Project",
    personalization: Project.Personalization(
      backing: nil,
      friends: nil,
      isBacking: nil,
      isStarred: nil
    ),
    photo: .template,
    rewards: [],
    slug: "a-fun-project",
    state: .live,
    stats: Project.Stats(
      backersCount: 10,
      commentsCount: 10,
      currentCurrency: "USD",
      currentCurrencyRate: 1.5,
      goal: 2_000,
      pledged: 1_000,
      staticUsdRate: 1.0,
      updatesCount: 1
    ),
    urls: Project.UrlsEnvelope(
      web: Project.UrlsEnvelope.WebEnvelope(
        project: "https://www.kickstarter.com/projects/creator/a-fun-project",
        updates: "https://www.kickstarter.com/projects/creator/a-fun-project/posts"
      )
    ),
    video: .template
  )

  internal static let todayByScottThrift = .template
    |> Project.lens.photo.full .~ "https://ksr-ugc.imgix.net/assets/012/224/660/847bc4da31e6863e9351bee4e55b8005_original.jpg?w=560&h=315&fit=fill&bg=FBFAF8&v=1464773625&auto=format&q=92&s=bb3773aebc4ad41e145ed8735cb3a221"
    |> Project.lens.photo.med .~ "https://ksr-ugc.imgix.net/assets/012/224/660/847bc4da31e6863e9351bee4e55b8005_original.jpg?w=266&h=150&fit=fill&bg=FBFAF8&v=1464773625&auto=format&q=92&s=79a8051e6475e417ead9b0bfae63798b"
    |> Project.lens.photo.small .~ "https://ksr-ugc.imgix.net/assets/012/224/660/847bc4da31e6863e9351bee4e55b8005_original.jpg?w=160&h=90&fit=fill&bg=FBFAF8&v=1464773625&auto=format&q=92&s=fc738d87d861a96333e9f93bee680c27"
    |> Project.lens.name .~ "Today"
    |> Project.lens.blurb .~ "A 24-hour timepiece beautifully designed to change the way you see your day."
    |> Project.lens.category.name .~ "Product Design"
    |> Project.lens.stats.backersCount .~ 1_090
    |> Project.lens.stats.pledged .~ 212_870
    |> Project.lens.stats.goal .~ 24_000

  internal static let cosmicSurgery = .template
    |> Project.lens.photo.full .~ "https://ksr-ugc.imgix.net/assets/012/347/230/2eddca8c4a06ecb69b8787b985201b92_original.jpg?w=460&fit=max&v=1463756137&auto=format&q=92&s=98a6df348751e8b325e48eb8f802fa7e"
    |> Project.lens.photo.med .~ "https://ksr-ugc.imgix.net/assets/012/347/230/2eddca8c4a06ecb69b8787b985201b92_original.jpg?w=460&fit=max&v=1463756137&auto=format&q=92&s=98a6df348751e8b325e48eb8f802fa7e"
    |> Project.lens.photo.small .~ "https://ksr-ugc.imgix.net/assets/012/347/230/2eddca8c4a06ecb69b8787b985201b92_original.jpg?w=460&fit=max&v=1463756137&auto=format&q=92&s=98a6df348751e8b325e48eb8f802fa7e"
    |> Project.lens.name .~ "Cosmic Surgery"
    |> Project.lens.blurb .~ "Cosmic Surgery is a photo book, set in the not too distant future where the world of cosmetic surgery is about to be transformed."
    |> Project.lens.category.name .~ "Photo Books"
    |> Project.lens.stats.backersCount .~ 329
    |> Project.lens.stats.pledged .~ 22_318
    |> Project.lens.stats.goal .~ 22_000
    |> Project.lens.stats.staticUsdRate .~ 1.31
    |> Project.lens.stats.currentCurrency .~ "USD"
    |> Project.lens.stats.currentCurrencyRate .~ 1.31
    |> (Project.lens.location..Location.lens.displayableName) .~ "Hastings, UK"
    |> Project.lens.rewards .~ [
      .template
        |> Reward.lens.id .~ 20
        |> Reward.lens.minimum .~ 6
        |> Reward.lens.limit .~ nil
        |> Reward.lens.backersCount .~ 23
        |> Reward.lens.title .~ "Postcards"
        |> Reward.lens.description .~ "Pack of 5 postcards - images from the Cosmic Surgery series.",

      .template
        |> Reward.lens.id .~ 1
        |> Reward.lens.minimum .~ 25
        |> Reward.lens.limit .~ 100
        |> Reward.lens.backersCount .~ 100
        |> Reward.lens.remaining .~ 0
        |> Reward.lens.title .~ "‘EARLYBIRD’ COSMIC SURGERY BOOK"
        |> Reward.lens.description .~ "You will be the first to receive a copy of the book at this special ‘earlybird’ price. Limited to the first 100 copies.",

      .template
        |> Reward.lens.id .~ 2
        |> Reward.lens.minimum .~ 30
        |> Reward.lens.backersCount .~ 83
        |> Reward.lens.title .~ "COSMIC SURGERY BOOK"
        |> Reward.lens.description .~ "You will be the first to receive a copy of the book at the special price of £30. The book will be sold for £35 in shops when released in July.",

      .template
        |> Reward.lens.id .~ 3
        |> Reward.lens.minimum .~ 650
        |> Reward.lens.limit .~ 10
        |> Reward.lens.backersCount .~ 3
        |> Reward.lens.title .~ "‘PATIENT NO. 16’ PRINT"
        |> Reward.lens.description .~ "This is a newly released print available in the Cosmic Surgery print series."
        |> Reward.lens.rewardsItems .~ [
          .template
            |> RewardsItem.lens.id .~ 1
            |> RewardsItem.lens.item .~ (
              .template
                |> Item.lens.description .~ "60x60cm Fine Art Print on Fine Art Felt 310gsm Paper. Edition of 10."
                |> Item.lens.name .~ "60x60cm Fine Art Print on Fine Art Felt 310gsm Paper. Edition of 10."
            )
            |> RewardsItem.lens.quantity .~ 1
            |> RewardsItem.lens.rewardId .~ 3,

          .template
            |> RewardsItem.lens.id .~ 1
            |> RewardsItem.lens.item .~ (
              .template
                |> Item.lens.description .~ "Signed copy of book."
                |> Item.lens.name .~ "Signed copy of book."
            )
            |> RewardsItem.lens.quantity .~ 1
            |> RewardsItem.lens.rewardId .~ 3,

          .template
            |> RewardsItem.lens.id .~ 1
            |> RewardsItem.lens.item .~ (
              .template
                |> Item.lens.description .~ "Invite to book launch party."
                |> Item.lens.name .~ "Invite to book launch party."
            )
            |> RewardsItem.lens.quantity .~ 1
            |> RewardsItem.lens.rewardId .~ 3,
      ]
    ]
    |> Project.lens.country .~ .gb
    |> Project.lens.creator .~ (
      .template
        |> User.lens.id .~ "Alma Haser".hash
        |> User.lens.name .~ "Alma Haser"
        |> User.lens.avatar.large .~ "https://ksr-ugc.imgix.net/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?w=80&h=80&fit=crop&v=1461378633&auto=format&q=92&s=68edc5b8d1b110634b59589253801ea1"
        |> User.lens.avatar.medium .~ "https://ksr-ugc.imgix.net/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?w=80&h=80&fit=crop&v=1461378633&auto=format&q=92&s=68edc5b8d1b110634b59589253801ea1"
        |> User.lens.avatar.small .~ "https://ksr-ugc.imgix.net/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?w=80&h=80&fit=crop&v=1461378633&auto=format&q=92&s=68edc5b8d1b110634b59589253801ea1"
    )
    |> Project.lens.urls.web.project .~ "https://www.kickstarter.com/projects/1171937901/cosmic-surgery"

  internal static let anomalisa = .template
    |> Project.lens.photo.full .~ "https://ksr-ugc.imgix.net/assets/011/388/954/25e113da402393de9de995619428d10d_original.png?w=1024&h=576&fit=fill&bg=000000&v=1463681956&auto=format&q=92&s=2a9b6a90e1f52b96d7cbdcad28319f9d"
    |> Project.lens.photo.med .~ "https://ksr-ugc.imgix.net/assets/005/055/025/6e0d27710c9ae20d661e2974e99fe239_original.jpg?w=460&fit=max&v=1449722467&auto=format&q=92&s=cd67034e3ee1f363be0df4f5d3b5f728"
    |> Project.lens.name .~ "Charlie Kaufman's Anomalisa"
    |> Project.lens.blurb .~ "From writer Charlie Kaufman (Being John Malkovich, Eternal Sunshine of the Spotless Mind) and Duke Johnson (Moral Orel, Frankenhole) comes Anomalisa."
    |> Project.lens.category.name .~ "Animation"
    |> Project.lens.stats.backersCount .~ 5_770
    |> Project.lens.stats.pledged .~ 406_237
    |> Project.lens.stats.goal .~ 200_000
    |> (Project.lens.location..Location.lens.displayableName) .~ "Burbank, CA"
}
