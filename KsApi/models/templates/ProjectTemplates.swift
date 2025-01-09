import Foundation
import Prelude

// swiftformat:disable wrap
extension Project {
  internal static let template = Project(
    availableCardTypes: [
      "AMEX",
      "MASTERCARD",
      "VISA",
      "DISCOVER",
      "JCB",
      "DINERS",
      "UNION_PAY"
    ],
    blurb: "A fun project.",
    category: .template,
    country: .us,
    creator: User.template |> \.stats.createdProjectsCount .~ 2,
    memberData: Project.MemberData(
      lastUpdatePublishedAt: nil,
      permissions: [],
      unreadMessagesCount: nil,
      unseenActivityCount: nil
    ),
    dates: Project.Dates(
      deadline: Date(timeIntervalSince1970: 1_475_361_315).timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 15.0,
      featuredAt: nil,
      launchedAt: Date(timeIntervalSince1970: 1_475_361_315).timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 15.0,
      stateChangedAt: Date(
        timeIntervalSince1970: 1_475_361_315
      ).timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 15.0
    ),
    displayPrelaunch: nil,
    flagging: false,
    id: 1,
    location: .template,
    name: "The Project",
    pledgeOverTimeMinimumExplanation: "Available for pledges over $125",
    personalization: Project.Personalization(
      backing: nil,
      friends: nil,
      isBacking: nil,
      isStarred: nil
    ),
    photo: .template,
    isInPostCampaignPledgingPhase: false,
    postCampaignPledgingEnabled: false,
    prelaunchActivated: nil,
    rewardData: RewardData(addOns: nil, rewards: []),
    sendMetaCapiEvents: false,
    slug: "a-fun-project",
    staffPick: false,
    state: .live,
    stats: .template,
    tags: ["Action & Adventure", "Adaptation", "Board Games"],
    urls: Project.UrlsEnvelope(
      web: Project.UrlsEnvelope.WebEnvelope(
        project: "https://www.kickstarter.com/projects/creator/a-fun-project",
        updates: "https://www.kickstarter.com/projects/creator/a-fun-project/posts"
      )
    ),
    video: .template,
    isPledgeOverTimeAllowed: false
  )

  internal static let todayByScottThrift = Project.template
    |> Project.lens.photo.full .~ "https://i.kickstarter.com/assets/012/224/660/847bc4da31e6863e9351bee4e55b8005_original.jpg?fit=pad&height=315&origin=ugc&q=92&width=560&sig=xdjobguK6cfILWmRb%2FXg%2ByVslW9%2BhAwPsdUS1tPbsaE%3D"
    |> Project.lens.photo.med .~ "https://i.kickstarter.com/assets/012/224/660/847bc4da31e6863e9351bee4e55b8005_original.jpg?fit=pad&height=150&origin=ugc&q=92&width=266&sig=bSHOMsIt4qZs4xu49aDtCHdvW5TY%2B56t%2FKsqzTcJ%2Fvg%3D"
    |> Project.lens.photo.small .~ "https://i.kickstarter.com/assets/012/224/660/847bc4da31e6863e9351bee4e55b8005_original.jpg?fit=pad&height=90&origin=ugc&q=92&width=160&sig=rOHQ6Fif6TxwI%2BL8F9RQY0wUgN%2F4yusD%2FTGXhYW8w%2FQ%3D"
    |> Project.lens.name .~ "Today"
    |> Project.lens.blurb .~ "A 24-hour timepiece beautifully designed to change the way you see your day."
    |> \.category.name .~ "Product Design"
    |> Project.lens.stats.backersCount .~ 1_090
    |> Project.lens.stats.pledged .~ 212_870
    |> Project.lens.stats.goal .~ 24_000

  internal static let cosmicSurgery = .template
    |> Project.lens.photo.full .~ "https://i.kickstarter.com/assets/012/347/230/2eddca8c4a06ecb69b8787b985201b92_original.jpg?fit=contain&origin=ugc&q=92&width=460&sig=ewWbTA9q%2BTNYpB9KQnwXKCfjCJum57sWhpZkp%2FiwHKY%3D"
    |> Project.lens.photo.med .~ "https://i.kickstarter.com/assets/012/347/230/2eddca8c4a06ecb69b8787b985201b92_original.jpg?fit=contain&origin=ugc&q=92&width=460&sig=ewWbTA9q%2BTNYpB9KQnwXKCfjCJum57sWhpZkp%2FiwHKY%3D"
    |> Project.lens.photo.small .~ "https://i.kickstarter.com/assets/012/347/230/2eddca8c4a06ecb69b8787b985201b92_original.jpg?fit=contain&origin=ugc&q=92&width=460&sig=ewWbTA9q%2BTNYpB9KQnwXKCfjCJum57sWhpZkp%2FiwHKY%3D"
    |> Project.lens.name .~ "Cosmic Surgery"
    |> Project.lens.blurb .~ "Cosmic Surgery is a photo book, set in the not too distant future where the world of cosmetic surgery is about to be transformed."
    |> \.category.name .~ "Photo Books"
    |> Project.lens.stats.backersCount .~ 329
    |> Project.lens.stats.pledged .~ 22_318
    |> Project.lens.stats.goal .~ 22_000
    |> Project.lens.stats.staticUsdRate .~ 1.31
    |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
    |> Project.lens.stats.currentCurrency .~ "USD"
    |> Project.lens.stats.currentCurrencyRate .~ 1.31
    |> (Project.lens.location .. Location.lens.displayableName) .~ "Hastings, UK"
    |> Project.lens.country .~ .gb
    |> Project.lens.creator .~ (
      User.template
        |> \.id .~ "Alma Haser".hash
        |> \.name .~ "Alma Haser"
        |> \.avatar.large .~ "https://i.kickstarter.com/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?fit=crop&height=80&origin=ugc&q=92&width=80&sig=fVf5SA513LFbbFr5PYXBGGzhuW%2FktUYIBG1NxAaA8zg%3D"
        |> \.avatar.medium .~ "https://i.kickstarter.com/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?fit=crop&height=80&origin=ugc&q=92&width=80&sig=fVf5SA513LFbbFr5PYXBGGzhuW%2FktUYIBG1NxAaA8zg%3D"
        |> \.avatar.small .~ "https://i.kickstarter.com/assets/006/286/957/203502774070f5c0bf5ddcbb58e13000_original.jpg?fit=crop&height=80&origin=ugc&q=92&width=80&sig=fVf5SA513LFbbFr5PYXBGGzhuW%2FktUYIBG1NxAaA8zg%3D"
    )
    |> Project.lens.urls.web.project .~ "https://www.kickstarter.com/projects/1171937901/cosmic-surgery"
    |> Project.lens.rewardData.rewards .~ cosmicSurgeryRewards
    |> Project.lens.displayPrelaunch .~ false

  internal static let anomalisa = .template
    |> Project.lens.photo.full .~ "https://i.kickstarter.com/assets/011/388/954/25e113da402393de9de995619428d10d_original.png?fit=pad&height=576&origin=ugc&q=92&width=1024&sig=QslMsLq5k%2FKSU14VswLzhLhPL2M9RueInm6bFBVb5EY%3D"
    |> Project.lens.photo.med .~ "https://i.kickstarter.com/assets/005/055/025/6e0d27710c9ae20d661e2974e99fe239_original.jpg?fit=contain&origin=ugc&q=92&width=460&sig=C05wZhm%2Fm7cw9lbn9H05zOhA8ApoQ%2Bu%2FCAO%2FuGJDMo0%3D"
    |> Project.lens.name .~ "Charlie Kaufman's Anomalisa"
    |> Project.lens.blurb .~ "From writer Charlie Kaufman (Being John Malkovich, Eternal Sunshine of the Spotless Mind) and Duke Johnson (Moral Orel, Frankenhole) comes Anomalisa."
    |> \.category.name .~ "Animation"
    |> Project.lens.stats.backersCount .~ 5_770
    |> Project.lens.stats.pledged .~ 406_237
    |> Project.lens.stats.goal .~ 200_000
    |> (Project.lens.location .. Location.lens.displayableName) .~ "Burbank, CA"
}

private let cosmicSurgeryRewards: [Reward] = [
  Reward.template
    |> Reward.lens.id .~ 20
    |> Reward.lens.minimum .~ 6.0
    |> Reward.lens.convertedMinimum .~ 7.0
    |> Reward.lens.limit .~ nil
    |> Reward.lens.backersCount .~ 23
    |> Reward.lens.title .~ "Postcards"
    |> Reward.lens.description .~ "Pack of 5 postcards - images from the Cosmic Surgery series."
    |> Reward.lens.localPickup .~ nil,

  .template
    |> Reward.lens.id .~ 1
    |> Reward.lens.minimum .~ 25.0
    |> Reward.lens.convertedMinimum .~ 32.0
    |> Reward.lens.limit .~ 100
    |> Reward.lens.backersCount .~ 100
    |> Reward.lens.remaining .~ 0
    |> Reward.lens.title .~ "‘EARLYBIRD’ COSMIC SURGERY BOOK"
    |> Reward.lens.description .~ "You will be the first to receive a copy of the book at this special ‘earlybird’ price. Limited to the first 100 copies."
    |> Reward.lens.localPickup .~ nil,

  .template
    |> Reward.lens.id .~ 2
    |> Reward.lens.minimum .~ 30.0
    |> Reward.lens.convertedMinimum .~ 39.0
    |> Reward.lens.backersCount .~ 83
    |> Reward.lens.title .~ "COSMIC SURGERY BOOK"
    |> Reward.lens.description .~ "You will be the first to receive a copy of the book at the special price of £30. The book will be sold for £35 in shops when released in July."
    |> Reward.lens.localPickup .~ nil,

  .template
    |> Reward.lens.id .~ 3
    |> Reward.lens.minimum .~ 650.0
    |> Reward.lens.convertedMinimum .~ 851.0
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
        |> RewardsItem.lens.rewardId .~ 3
    ]
    |> Reward.lens.localPickup .~ nil
]
