import Foundation
import KsApi

public protocol HasProjectPamphletMainCellProperties {
  var projectPamphletMainCellProperties: ProjectPamphletMainCellProperties { get }
}

public typealias ProjectPamphletMainCellConfiguration =
  HasProjectAnalyticsProperties &
  HasProjectCreatorProperties &
  HasProjectPamphletMainCellProperties &
  HasProjectWebURL &
  HasVideoViewProperties

public struct ProjectPamphletMainCellProperties {
  public typealias Money = (amount: Int, currency: String, symbol: String)

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
  public let fxRate: Float
  public let usdExchangeRate: Float
  public let projectUsdExchangeRate: Float
  public let goal: Money
  public let pledged: Money
  public let convertedPledgedAmount: Float?
  public let currency: String
  public let userCurrency: String?
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
    fxRate: Float,
    usdExchangeRate: Float,
    projectUsdExchangeRate: Float,
    goal: Money,
    pledged: Money,
    convertedPledgedAmount: Float?,
    currency: String,
    userCurrency: String?,
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
    self.fxRate = fxRate
    self.usdExchangeRate = usdExchangeRate
    self.projectUsdExchangeRate = projectUsdExchangeRate
    self.goal = goal
    self.pledged = pledged
    self.convertedPledgedAmount = convertedPledgedAmount
    self.currency = currency
    self.userCurrency = userCurrency
    self.country = country
    self.projectNotice = projectNotice
    self.video = video
    self.webURL = webURL
  }
}

extension ProjectPamphletMainCellProperties: HasVideoViewProperties {
  public var videoViewProperties: VideoViewProperties {
    VideoViewProperties(video: self.video, photoFull: self.photo)
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
      fxRate: self.stats.userCurrencyRate ?? self.stats.staticUsdRate,
      usdExchangeRate: self.stats.staticUsdRate,
      projectUsdExchangeRate: self.stats.usdExchangeRate ?? self.stats.staticUsdRate,
      goal: (amount: self.stats.goal, currency: self.statsCurrency, symbol: self.country.currencySymbol),
      pledged: (
        amount: self.stats.pledged,
        currency: self.statsCurrency,
        symbol: self.country.currencySymbol
      ),
      convertedPledgedAmount: self.stats.convertedPledgedAmount,
      currency: self.stats.projectCurrency,
      userCurrency: self.stats.userCurrency,
      country: self.country,
      projectNotice: self.extendedProjectProperties?.projectNotice,
      video: self.video.map { ($0.hls, $0.high) },
      webURL: self.urls.web.project
    )
  }
}

extension ProjectPamphletMainCellProperties {
  /// Percent funded as measured from `0.0` to `1.0`. See `percentFunded` for a value from `0` to `100`.
  public var fundingProgress: Float {
    return self.goal.amount == 0 ? 0.0 : Float(self.pledged.amount) / Float(self.goal.amount)
  }

  /// Pledged amount converted to USD.
  public var pledgedUsd: Float {
    floor(Float(self.pledged.amount) * self.usdExchangeRate)
  }

  /// Total amount currently pledged to the project, converted to USD, irrespective of the users selected currency
  public var totalAmountPledgedUsdCurrency: Float? {
    Float(self.pledged.amount) * self.usdExchangeRate
  }

  /// Goal amount converted to USD.
  public var goalUsd: Float {
    floor(Float(self.goal.amount) * self.usdExchangeRate)
  }

  /// Goal amount converted to current currency.
  public var goalCurrentCurrency: Float? {
    floor(Float(self.goal.amount) * self.fxRate)
  }

  /// Goal amount, converted to USD, irrespective of the users selected currency
  public var goalUsdCurrency: Float {
    Float(self.goal.amount) * (self.usdExchangeRate)
  }

  /// Country determined by current currency.
  public var currentCountry: Project.Country? {
    self.userCurrency.flatMap(Project.Country.init(currencyCode:))
  }

  /// Omit US currency code
  public var omitUSCurrencyCode: Bool {
    self.currentCurrency == Project.Country.us.currencyCode
  }

  /// Project pledge & goal values need conversion
  public var needsConversion: Bool {
    self.currency != self.currentCurrency
  }

  public var goalMet: Bool {
    self.pledged >= self.goal
  }

  public var currentCurrency: String {
    self.userCurrency ?? getCurrentCurrency()
  }
}

private func getCurrentCurrency() -> String {
  AppEnvironment.current.currentUser?.chosenCurrency ?? Project.Country.us.currencyCode
}
