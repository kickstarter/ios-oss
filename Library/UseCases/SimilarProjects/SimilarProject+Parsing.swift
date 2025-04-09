import Foundation
import Kingfisher
import KsApi

internal struct SimilarProjectFragment: SimilarProject {
  let projectID: Int
  let image: Kingfisher.Source
  let name: String
  let isLaunched: Bool
  let isPrelaunchActivated: Bool
  let isInPostCampaignPledgingPhase: Bool
  let isPostCampaignPledgingEnabled: Bool
  let launchedAt: Date?
  let deadlineAt: Date?
  let percentFunded: Int
  let state: Project.State
  let goal: Money?
  let pledged: Money?
  let url: String

  private let projectAnalytics: any ProjectAnalyticsProperties
  private let projectPamphletMainCell: any HasProjectPamphletMainCellProperties

  init?(_ fragment: GraphAPI.ProjectCardFragment) {
    guard
      let imageURLString = fragment.image?.url,
      let imageURL = URL(string: imageURLString),
      let state = Project.State(fragment.state)
    else {
      return nil
    }

    func timestamp(from: String?) -> Date? {
      from
        .flatMap { timestamp in Int(timestamp) }
        .flatMap { timestamp in Date(timeIntervalSince1970: TimeInterval(timestamp)) }
    }

    let launchedAt = timestamp(from: fragment.launchedAt)
    let deadlineAt = timestamp(from: fragment.deadlineAt)

    self.projectID = fragment.pid
    self.image = .network(imageURL)
    self.name = fragment.name
    self.isLaunched = fragment.isLaunched
    self.isPrelaunchActivated = fragment.prelaunchActivated
    self.isInPostCampaignPledgingPhase = fragment.isInPostCampaignPledgingPhase
    self.isPostCampaignPledgingEnabled = fragment.postCampaignPledgingEnabled
    self.launchedAt = launchedAt
    self.deadlineAt = deadlineAt
    self.percentFunded = fragment.percentFunded
    self.state = state
    self.goal = (fragment.goal?.fragments.moneyFragment).flatMap(Money.init)
    self.pledged = Money(fragment.pledged.fragments.moneyFragment)
    self.url = fragment.url

    self.projectAnalytics = fragment.fragments.projectAnalyticsFragment
    self.projectPamphletMainCell = fragment.fragments.projectPamphletMainCellPropertiesFragment
  }
}

extension SimilarProjectFragment: ProjectPamphletMainCellConfiguration {
  var projectAnalyticsProperties: any ProjectAnalyticsProperties {
    self.projectAnalytics
  }

  var projectPamphletMainCellProperties: ProjectPamphletMainCellProperties {
    self.projectPamphletMainCell.projectPamphletMainCellProperties
  }

  var projectCreatorProperties: ProjectCreatorProperties {
    ProjectCreatorProperties(id: self.projectID, name: self.name, projectWebURL: self.url)
  }

  var serviceProjectWebURL: ServiceProjectWebURL {
    ServiceProjectWebURL(projectWebURL: self.url)
  }

  var videoViewProperties: any VideoViewProperties {
    self.projectPamphletMainCellProperties.videoViewProperties
  }
}

extension GraphAPI.ProjectPamphletMainCellPropertiesFragment: HasProjectPamphletMainCellProperties {
  public var projectPamphletMainCellProperties: ProjectPamphletMainCellProperties {
    func moneyFragmentToMoney(_ fragment: GraphAPI.MoneyFragment?) -> ProjectPamphletMainCellProperties
      .Money {
      return (
        amount: Int(Double(fragment?.amount ?? "0") ?? 0),
        currency: fragment?.currency?.rawValue ?? "",
        symbol: fragment?.symbol ?? ""
      )
    }

    let state: Project.State
    switch self.state {
    case .started:
      state = .started
    case .submitted:
      state = .submitted
    case .live:
      state = .live
    case .canceled:
      state = .canceled
    case .suspended:
      state = .suspended
    case .purged:
      state = .purged
    case .successful:
      state = .successful
    case .failed, .__unknown:
      state = .failed
    }

    let video: (hls: String?, high: String)?
    if let sources = self.video?.videoSources, let high = sources.high?.src {
      video = (hls: sources.hls?.src, high: high)
    } else {
      video = nil
    }

    return ProjectPamphletMainCellProperties(
      param: .id(self.pid),
      name: self.name,
      blurb: self.projectDescription,
      creatorName: self.creator?.name ?? "",
      creatorAvatarURL: self.creator?.imageUrl ?? "",
      creatorId: (self.creator?.id).flatMap(Int.init) ?? 0,
      isCreatorBlocked: self.creator?.isBlocked ?? false,
      state: state,
      stateChangedAt: TimeInterval(self.stateChangedAt) ?? 0,
      photo: self.image?.url ?? "",
      displayPrelaunch: nil,
      isBacking: self.backing.isSome,
      backersCount: self.backersCount,
      categoryName: self.category?.name ?? "",
      locationName: self.location?.displayableName ?? "",
      deadline: TimeInterval(self.deadlineAt ?? "0") ?? 0,
      usdExchangeRate: self.usdExchangeRate.flatMap(Float.init) ?? 0,
      projectUsdExchangeRate: Float(self.projectUsdExchangeRate),
      goal: moneyFragmentToMoney(self.goal?.fragments.moneyFragment),
      pledged: moneyFragmentToMoney(self.pledged.fragments.moneyFragment),
      currency: self.currency.rawValue,
      country: Project.Country(currencyCode: self.country.code.rawValue) ?? .us,
      projectNotice: "",
      video: video,
      webURL: self.url
    )
  }
}
