import Foundation
import KsApi

public protocol HasProjectPamphletMainCellProperties {
  var projectPamphletMainCellProperties: ProjectPamphletMainCellProperties { get }
}

public typealias ProjectPamphletMainCellConfiguration = HasProjectPamphletMainCellProperties &
  ProjectAnalyticsProperties &
  ProjectCreatorConfiguration &
  VideoViewConfiguration

public struct ProjectPamphletMainCellProperties {
  public let param: Param
  public let name: String
  public let blurb: String
  public let creatorName: String
  public let creatorAvatarURL: String
  public let creatorId: Int
  public let isCreatorBlocked: Bool
  public let state: Project.State
  public let stateChangedAt: TimeInterval
  public let photo: String
  public let displayPrelaunch: Bool?
  public let isBacking: Bool?
  public let backersCount: Int
  public let categoryName: String
  public let locationName: String
  public let deadline: TimeInterval?
  public let needsConversion: Bool
  public let fundingProgress: Float
  public let goal: Int
  public let pledged: Int
  public let goalCurrentCurrency: Float?
  public let convertedPledgedAmount: Float?
  public let currentCountry: Project.Country?
  public let pledgedUsd: Float
  public let goalUsd: Float
  public let omitUSCurrencyCode: Bool
  public let currency: String
  public let country: Project.Country
  public let projectNotice: String?
  public let video: (hls: String?, high: String)?
  public let webURL: String

  public init(
    param: Param,
    name: String,
    blurb: String,
    creatorName: String,
    creatorAvatarURL: String,
    creatorId: Int,
    isCreatorBlocked: Bool,
    state: Project.State,
    stateChangedAt: TimeInterval,
    photo: String,
    displayPrelaunch: Bool?,
    isBacking: Bool?,
    backersCount: Int,
    categoryName: String,
    locationName: String,
    deadline: TimeInterval?,
    needsConversion: Bool,
    fundingProgress: Float,
    goal: Int,
    pledged: Int,
    goalCurrentCurrency: Float?,
    convertedPledgedAmount: Float?,
    currentCountry: Project.Country?,
    pledgedUsd: Float,
    goalUsd: Float,
    omitUSCurrencyCode: Bool,
    currency: String,
    country: Project.Country,
    projectNotice: String?,
    video: (hls: String?, high: String)?,
    webURL: String
  ) {
    self.param = param
    self.name = name
    self.blurb = blurb
    self.creatorName = creatorName
    self.creatorAvatarURL = creatorAvatarURL
    self.creatorId = creatorId
    self.isCreatorBlocked = isCreatorBlocked
    self.state = state
    self.stateChangedAt = stateChangedAt
    self.photo = photo
    self.displayPrelaunch = displayPrelaunch
    self.isBacking = isBacking
    self.backersCount = backersCount
    self.categoryName = categoryName
    self.locationName = locationName
    self.deadline = deadline
    self.needsConversion = needsConversion
    self.fundingProgress = fundingProgress
    self.goal = goal
    self.pledged = pledged
    self.goalCurrentCurrency = goalCurrentCurrency
    self.convertedPledgedAmount = convertedPledgedAmount
    self.currentCountry = currentCountry
    self.pledgedUsd = pledgedUsd
    self.goalUsd = goalUsd
    self.omitUSCurrencyCode = omitUSCurrencyCode
    self.currency = currency
    self.country = country
    self.projectNotice = projectNotice
    self.video = video
    self.webURL = webURL
  }
}

extension Project: HasProjectPamphletMainCellProperties {
  public var projectPamphletMainCellProperties: ProjectPamphletMainCellProperties {
    ProjectPamphletMainCellProperties(
      param: .id(self.id),
      name: self.name,
      blurb: self.blurb,
      creatorName: self.creator.name,
      creatorAvatarURL: self.creator.avatar.small,
      creatorId: self.creator.id,
      isCreatorBlocked: self.creator.isBlocked,
      state: self.state,
      stateChangedAt: self.dates.stateChangedAt,
      photo: self.photo.full,
      displayPrelaunch: self.displayPrelaunch,
      isBacking: self.personalization.isBacking,
      backersCount: self.stats.backersCount,
      categoryName: self.category.name,
      locationName: self.location.displayableName,
      deadline: self.dates.deadline,
      needsConversion: self.stats.needsConversion,
      fundingProgress: self.stats.fundingProgress,
      goal: self.stats.goal,
      pledged: self.stats.pledged,
      goalCurrentCurrency: self.stats.goalCurrentCurrency,
      convertedPledgedAmount: self.stats.convertedPledgedAmount,
      currentCountry: self.stats.currentCountry,
      pledgedUsd: self.stats.pledgedUsd,
      goalUsd: self.stats.goalUsd,
      omitUSCurrencyCode: self.stats.omitUSCurrencyCode,
      currency: self.stats.currency,
      country: self.country,
      projectNotice: self.extendedProjectProperties?.projectNotice,
      video: self.video.map { ($0.hls, $0.high) },
      webURL: self.urls.web.project
    )
  }
}
