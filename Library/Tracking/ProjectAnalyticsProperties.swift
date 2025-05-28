import Foundation

public protocol HasProjectAnalyticsProperties {
  var projectAnalyticsProperties: ProjectAnalyticsProperties { get }
}

public protocol ProjectAnalyticsProperties {
  var categoryAnalyticsName: String? { get }
  var categoryParentAnalyticsName: String? { get }
  var categoryParentId: String? { get }

  var countryCode: String { get }

  var creatorId: String? { get }
  var creatorIsRepeatCreator: Bool? { get }

  var datesDeadline: TimeInterval? { get }
  var datesLaunchedAt: TimeInterval? { get }
  func datesDuration(using calendar: Calendar) -> Int?
  func datesHoursRemaining(from date: Date, using calendar: Calendar) -> Int?

  var id: Int { get }
  var hasAddOns: Bool { get }
  var hasVideo: Bool { get }
  var name: String { get }
  var isInPostCampaignPledgingPhase: Bool { get }

  var personalizationIsStarred: Bool? { get }
  var personalizationIsBacking: Bool? { get }

  var postCampaignPledgingEnabled: Bool { get }
  var prelaunchActivated: Bool? { get }

  var rewardsCount: Int { get }

  var stateValue: String { get }

  var statsBackerCount: Int { get }
  var statsCommentsCount: Int? { get }
  var statsCurrency: String { get }
  var statsPercentFunded: Int { get }
  var statsPledged: Int { get }
  var statsTotalAmountPledgedUsdCurrency: Float? { get }
  var statsGoalUsdCurrency: Float? { get }
  var statsUpdatesCount: Int? { get }

  var tags: [String]? { get }
}

extension Project: HasProjectAnalyticsProperties {
  public var projectAnalyticsProperties: any ProjectAnalyticsProperties { self }
}

extension Project: ProjectAnalyticsProperties {
  public var categoryAnalyticsName: String? {
    self.category.analyticsName
  }

  public var categoryParentAnalyticsName: String? {
    self.category.parentAnalyticsName
  }

  public var categoryParentId: String? {
    self.category.parentId.flatMap(String.init)
  }

  public var countryCode: String {
    self.country.countryCode
  }

  public var creatorId: String? {
    String(self.creator.id)
  }

  public var creatorIsRepeatCreator: Bool? {
    self.creator.isRepeatCreator
  }

  public var datesDeadline: TimeInterval? {
    self.dates.deadline
  }

  public var datesLaunchedAt: TimeInterval? {
    self.dates.launchedAt
  }

  public func datesDuration(using calendar: Calendar) -> Int? {
    self.dates.duration(using: calendar)
  }

  public func datesHoursRemaining(from date: Date, using calendar: Calendar) -> Int? {
    self.dates.hoursRemaining(from: date, using: calendar)
  }

  public var hasVideo: Bool {
    self.video != nil
  }

  public var personalizationIsStarred: Bool? {
    self.personalization.isStarred
  }

  public var personalizationIsBacking: Bool? {
    self.personalization.isBacking
  }

  public var rewardsCount: Int {
    self.rewards.filter { $0 != .noReward }.count
  }

  public var stateValue: String {
    self.state.rawValue
  }

  public var statsBackerCount: Int {
    self.stats.backersCount
  }

  public var statsCommentsCount: Int? {
    self.stats.commentsCount
  }

  public var statsCurrency: String {
    self.stats.projectCurrency
  }

  public var statsPercentFunded: Int {
    self.stats.percentFunded
  }

  public var statsPledged: Int {
    self.stats.pledged
  }

  public var statsTotalAmountPledgedUsdCurrency: Float? {
    self.stats.totalAmountPledgedUsdCurrency
  }

  public var statsGoalUsdCurrency: Float? {
    self.stats.goalUsdCurrency
  }

  public var statsUpdatesCount: Int? {
    self.stats.updatesCount
  }
}

extension GraphAPI.ProjectAnalyticsFragment: ProjectAnalyticsProperties {
  public var prelaunchActivated: Bool? {
    self.isPrelaunchActivated
  }

  public var categoryAnalyticsName: String? {
    self.category?.analyticsName
  }

  public var categoryParentAnalyticsName: String? {
    self.category?.parentCategory?.analyticsName
  }

  public var categoryParentId: String? {
    self.category?.parentCategory?.id
  }

  public var countryCode: String {
    self.country.code.rawValue
  }

  public var creatorId: String? {
    self.creator?.id
  }

  public var creatorIsRepeatCreator: Bool? {
    (self.creator?.createdProjects?.totalCount ?? 0) >= 2
  }

  public var datesDeadline: TimeInterval? {
    self.deadlineAt.flatMap(TimeInterval.init)
  }

  public var datesLaunchedAt: TimeInterval? {
    self.launchedAt.flatMap(TimeInterval.init)
  }

  public func datesDuration(using calendar: Calendar = .current) -> Int? {
    guard let deadlineDateValue = self.datesDeadline,
          let launchedAtDateValue = self.datesLaunchedAt else {
      return nil
    }

    let deadlineDate = Date(timeIntervalSince1970: deadlineDateValue)
    let launchedAtDate = Date(timeIntervalSince1970: launchedAtDateValue)

    return calendar.dateComponents([.day], from: launchedAtDate, to: deadlineDate).day
  }

  public func datesHoursRemaining(from date: Date = Date(), using calendar: Calendar = .current) -> Int? {
    guard let deadlineDateValue = self.datesDeadline else {
      return nil
    }

    let deadlineDate = Date(timeIntervalSince1970: deadlineDateValue)

    guard let hoursRemaining = calendar.dateComponents([.hour], from: date, to: deadlineDate).hour else {
      return nil
    }

    return max(0, hoursRemaining)
  }

  public var id: Int {
    self.pid
  }

  public var hasAddOns: Bool {
    (self.addOns?.totalCount ?? 0) > 0
  }

  public var hasVideo: Bool {
    self.video != nil
  }

  public var personalizationIsStarred: Bool? {
    self.isWatched
  }

  public var personalizationIsBacking: Bool? {
    self.backing != nil
  }

  public var rewardsCount: Int {
    self.rewards?.totalCount ?? 0
  }

  public var stateValue: String {
    self.state.rawValue
  }

  public var statsBackerCount: Int {
    self.backersCount
  }

  public var statsCommentsCount: Int? {
    self.commentsCount
  }

  public var statsCurrency: String {
    self.currency.rawValue
  }

  public var statsPercentFunded: Int {
    self.percentFunded
  }

  public var statsPledged: Int {
    Int(self.pledged.amount ?? "") ?? 0
  }

  public var statsTotalAmountPledgedUsdCurrency: Float? {
    let amount = self.pledged.amount.flatMap(Float.init)
    return amount.flatMap { amount in self.usdExchangeRate.map { amount * Float($0) } }
  }

  public var statsGoalUsdCurrency: Float? {
    let amount = self.goal?.amount.flatMap(Float.init)
    return amount.flatMap { amount in self.usdExchangeRate.map { amount * Float($0) } }
  }

  public var statsUpdatesCount: Int? {
    self.posts?.totalCount
  }

  public var tags: [String]? {
    self.projectTags.compactMap { $0?.name }
  }
}
