import Foundation
import Prelude
import ReactiveSwift

public struct Project {
  public var availableCardTypes: [String]?
  public var blurb: String
  public var category: Category
  public var country: Country
  public var creator: User
  public var extendedProjectProperties: ExtendedProjectProperties?
  public var memberData: MemberData
  public var dates: Dates
  public var displayPrelaunch: Bool?
  public var flagging: Bool?
  public var id: Int
  public var lastWave: LastWave?
  public var location: Location
  public var name: String
  public var pledgeManager: PledgeManager?
  public var pledgeOverTimeCollectionPlanChargeExplanation: String?
  public var pledgeOverTimeCollectionPlanChargedAsNPayments: String?
  public var pledgeOverTimeCollectionPlanShortPitch: String?
  public var pledgeOverTimeMinimumExplanation: String?
  public var personalization: Personalization
  public var photo: Photo
  public var isInPostCampaignPledgingPhase: Bool
  public var postCampaignPledgingEnabled: Bool
  public var prelaunchActivated: Bool?
  public var redemptionPageUrl: String
  public var rewardData: RewardData
  public var sendMetaCapiEvents: Bool
  public var slug: String
  public var staffPick: Bool
  public var state: State
  public var stats: Stats
  public var tags: [String]?
  public var urls: UrlsEnvelope
  public var video: Video?
  public var watchesCount: Int?
  public var isPledgeOverTimeAllowed: Bool?

  public struct Category {
    public var analyticsName: String?
    public var id: Int
    public var name: String
    public var parentAnalyticsName: String?
    public var parentId: Int?
    public var parentName: String?

    public var rootId: Int {
      return self.parentId ?? self.id
    }
  }

  public struct UrlsEnvelope {
    public var web: WebEnvelope

    public struct WebEnvelope {
      public var project: String
      public var updates: String?
    }
  }

  public struct Video {
    public var id: Int
    public var high: String
    public var hls: String?
  }

  public enum State: String, CaseIterable, Decodable {
    case canceled
    case failed
    case live
    case purged
    case started
    case submitted
    case successful
    case suspended
  }

  public struct Stats {
    public var backersCount: Int
    public var commentsCount: Int?
    public var convertedPledgedAmount: Float?
    /// The currency code of the project ex. USD
    public var projectCurrency: String
    /// The currency code of the User's preferred currency ex. SEK
    public var userCurrency: String?
    /// The currency conversion rate between the User's preferred currency
    /// and the Project's currency
    public var userCurrencyRate: Float?
    public var goal: Int
    public var pledged: Int
    public var staticUsdRate: Float
    public var updatesCount: Int?
    public var usdExchangeRate: Float?

    /// Percent funded as measured from `0.0` to `1.0`. See `percentFunded` for a value from `0` to `100`.
    public var fundingProgress: Float {
      return self.goal == 0 ? 0.0 : Float(self.pledged) / Float(self.goal)
    }

    /// Percent funded as measured from `0` to `100`. See `fundingProgress` for a value between `0.0`
    /// and `1.0`.
    public var percentFunded: Int {
      return Int(floor(self.fundingProgress * 100.0))
    }

    /// Pledged amount converted to USD.
    public var pledgedUsd: Float {
      return floor(Float(self.pledged) * self.staticUsdRate)
    }

    /// Total amount currently pledged to the project, converted to USD, irrespective of the users selected currency
    public var totalAmountPledgedUsdCurrency: Float? {
      return self.usdExchangeRate.map { Float(self.pledged) * $0 }
    }

    /// Goal amount converted to USD.
    public var goalUsd: Float {
      return floor(Float(self.goal) * self.staticUsdRate)
    }

    /// Goal amount converted to user's currency.
    public var goalUserCurrency: Float? {
      return self.userCurrencyRate.map { floor(Float(self.goal) * $0) }
    }

    /// Goal amount, converted to USD, irrespective of the users selected currency
    public var goalUsdCurrency: Float {
      return Float(self.goal) * (self.usdExchangeRate ?? 0)
    }

    /// Country determined by user's currency.
    public var userCountry: Project.Country? {
      guard let userCurrency = self.userCurrency else {
        return nil
      }

      return Project.Country(currencyCode: userCurrency)
    }

    /// Omit US currency code
    public var omitUSCurrencyCode: Bool {
      let userCurrency = self.userCurrency ?? Project.Country.us.currencyCode

      return userCurrency == Project.Country.us.currencyCode
    }

    /// Project pledge & goal values need conversion
    public var needsConversion: Bool {
      let userCurrency = self.userCurrency ?? Project.Country.us.currencyCode

      return self.projectCurrency != userCurrency
    }

    public var goalMet: Bool {
      return self.pledged >= self.goal
    }
  }

  public struct MemberData {
    public var lastUpdatePublishedAt: TimeInterval?
    public var permissions: [Permission]
    public var unreadMessagesCount: Int?
    public var unseenActivityCount: Int?

    public enum Permission: String {
      case editProject = "edit_project"
      case editFaq = "edit_faq"
      case post
      case comment
      case viewPledges = "view_pledges"
      case fulfillment
      case unknown
    }
  }

  public struct Dates {
    public var deadline: TimeInterval?
    public var featuredAt: TimeInterval?
    public var finalCollectionDate: TimeInterval?
    public var launchedAt: TimeInterval?
    public var stateChangedAt: TimeInterval

    /**
     Returns project duration in Days
     */
    public func duration(using calendar: Calendar = .current) -> Int? {
      guard let deadlineDateValue = self.deadline,
            let launchedAtDateValue = self.launchedAt else {
        return nil
      }

      let deadlineDate = Date(timeIntervalSince1970: deadlineDateValue)
      let launchedAtDate = Date(timeIntervalSince1970: launchedAtDateValue)

      return calendar.dateComponents([.day], from: launchedAtDate, to: deadlineDate).day
    }

    public func hoursRemaining(from date: Date = Date(), using calendar: Calendar = .current) -> Int? {
      guard let deadlineDateValue = self.deadline else {
        return nil
      }

      let deadlineDate = Date(timeIntervalSince1970: deadlineDateValue)

      guard let hoursRemaining = calendar.dateComponents([.hour], from: date, to: deadlineDate).hour else {
        return nil
      }

      return max(0, hoursRemaining)
    }
  }

  public struct Personalization {
    public var backing: Backing?
    public var friends: [User]?
    public var isBacking: Bool?
    public var isStarred: Bool?
  }

  public struct Photo {
    public var full: String
    public var med: String
    public var size1024x768: String?
    public var small: String
  }

  public struct RewardData {
    public var addOns: [Reward]?
    public var rewards: [Reward]
  }

  public var hasAddOns: Bool {
    return self.addOns?.isEmpty == false
  }

  public var addOns: [Reward]? {
    return self.rewardData.addOns
  }

  public var rewards: [Reward] {
    return self.rewardData.rewards
  }

  public func endsIn48Hours(today: Date = Date()) -> Bool {
    guard let datesDeadlineValue = self.dates.deadline else {
      return true
    }

    let twoDays: TimeInterval = 60.0 * 60.0 * 48.0
    return datesDeadlineValue - today.timeIntervalSince1970 <= twoDays
  }

  public func isFeaturedToday(today: Date = Date(), calendar: Calendar = .current) -> Bool {
    guard let featuredAt = self.dates.featuredAt else { return false }
    return self.isDateToday(date: featuredAt, today: today, calendar: calendar)
  }

  private func isDateToday(date: TimeInterval, today: Date, calendar: Calendar) -> Bool {
    let startOfToday = calendar.startOfDay(for: today)
    return abs(startOfToday.timeIntervalSince1970 - date) < 60.0 * 60.0 * 24.0
  }
}

extension Project: Equatable {}
public func == (lhs: Project, rhs: Project) -> Bool {
  return lhs.id == rhs.id
}

extension Project: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "Project(id: \(self.id), name: \"\(self.name)\")"
  }
}

extension Project: Decodable {
  enum CodingKeys: String, CodingKey {
    case availableCardTypes = "available_card_types"
    case blurb
    case category
    case creator
    case displayPrelaunch = "display_prelaunch"
    case flagging
    case id
    case lastWave
    case location
    case name
    case photo
    case pledgeManager
    case pledgeOverTimeCollectionPlanChargeExplanation = "pledge_over_time_collection_plan_charge_explanation"
    case pledgeOverTimeCollectionPlanChargedAsNPayments =
      "pledge_over_time_collection_plan_charged_as_n_payments"
    case pledgeOverTimeCollectionPlanShortPitch = "pledge_over_time_collection_plan_short_pitch"
    case pledgeOverTimeMinimumExplanation = "pledge_over_time_minimum_explanation"
    case isInPostCampaignPledgingPhase = "is_in_post_campaign_pledging_phase"
    case postCampaignPledgingEnabled = "post_campaign_pledging_enabled"
    case prelaunchActivated = "prelaunch_activated"
    case redemptionPageUrl
    case sendMetaCapiEvents = "send_meta_capi_events"
    case slug
    case staffPick = "staff_pick"
    case state
    case tags
    case urls
    case video
    case isPledgeOverTimeAllowed
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.availableCardTypes = try values.decodeIfPresent([String].self, forKey: .availableCardTypes)
    self.blurb = try values.decode(String.self, forKey: .blurb)
    self.category = try values.decode(Category.self, forKey: .category)
    self.country = try Project.Country(from: decoder)
    self.creator = try values.decode(User.self, forKey: .creator)
    self.memberData = try Project.MemberData(from: decoder)
    self.dates = try Project.Dates(from: decoder)
    self.displayPrelaunch = try values.decodeIfPresent(Bool.self, forKey: .displayPrelaunch)
    self.extendedProjectProperties = nil
    self.flagging = try values.decodeIfPresent(Bool.self, forKey: .flagging) ?? false
    self.id = try values.decode(Int.self, forKey: .id)
    self.lastWave = try values.decodeIfPresent(LastWave.self, forKey: .lastWave)
    self.location = (try? values.decodeIfPresent(Location.self, forKey: .location)) ?? Location.none
    self.name = try values.decode(String.self, forKey: .name)
    self.personalization = try Project.Personalization(from: decoder)
    self.photo = try values.decode(Photo.self, forKey: .photo)
    self.isInPostCampaignPledgingPhase =
      try values.decodeIfPresent(Bool.self, forKey: .isInPostCampaignPledgingPhase) ?? false
    self.pledgeManager = try values.decodeIfPresent(PledgeManager.self, forKey: .pledgeManager)
    self.pledgeOverTimeCollectionPlanChargeExplanation = try values.decodeIfPresent(
      String.self,
      forKey: .pledgeOverTimeCollectionPlanChargeExplanation
    ) ?? ""
    self.pledgeOverTimeCollectionPlanChargedAsNPayments = try values.decodeIfPresent(
      String.self,
      forKey: .pledgeOverTimeCollectionPlanChargedAsNPayments
    ) ?? ""
    self.pledgeOverTimeCollectionPlanShortPitch = try values.decodeIfPresent(
      String.self,
      forKey: .pledgeOverTimeCollectionPlanShortPitch
    ) ?? ""
    self.pledgeOverTimeMinimumExplanation = try values.decodeIfPresent(
      String.self,
      forKey: .pledgeOverTimeMinimumExplanation
    ) ?? ""
    self.postCampaignPledgingEnabled =
      try values.decodeIfPresent(Bool.self, forKey: .postCampaignPledgingEnabled) ?? false
    self.prelaunchActivated = try values.decodeIfPresent(Bool.self, forKey: .prelaunchActivated)
    self.redemptionPageUrl = try values.decodeIfPresent(String.self, forKey: .redemptionPageUrl) ?? ""
    self.rewardData = try Project.RewardData(from: decoder)
    self.sendMetaCapiEvents = try values.decodeIfPresent(Bool.self, forKey: .sendMetaCapiEvents) ?? false
    self.slug = try values.decode(String.self, forKey: .slug)
    self.staffPick = try values.decode(Bool.self, forKey: .staffPick)
    self.state = try values.decode(State.self, forKey: .state)
    self.stats = try Project.Stats(from: decoder)
    self.tags = try values.decodeIfPresent([String].self, forKey: .tags)
    self.urls = try values.decode(UrlsEnvelope.self, forKey: .urls)
    self.video = try values.decodeIfPresent(Video.self, forKey: .video)
    self.watchesCount = nil
    self.isPledgeOverTimeAllowed =
      try values.decodeIfPresent(Bool.self, forKey: .isPledgeOverTimeAllowed)
  }
}

extension Project.UrlsEnvelope: Decodable {
  enum CodingKeys: String, CodingKey {
    case web
  }
}

extension Project.UrlsEnvelope.WebEnvelope: Decodable {
  enum CodingKeys: String, CodingKey {
    case project
    case updates
  }
}

extension Project.Stats: Decodable {
  enum CodingKeys: String, CodingKey {
    case backersCount = "backers_count"
    case commentsCount = "comments_count"
    case convertedPledgedAmount = "converted_pledged_amount"
    case currency
    case currentCurrency = "current_currency"
    case currentCurrencyRate = "fx_rate"
    case goal
    case pledged
    case staticUsdRate = "static_usd_rate"
    case updatesCount = "updates_count"
    case usdExchangeRate = "usd_exchange_rate"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.backersCount = try values.decode(Int.self, forKey: .backersCount)
    self.commentsCount = try values.decodeIfPresent(Int.self, forKey: .commentsCount)
    self.convertedPledgedAmount = try values.decodeIfPresent(Float.self, forKey: .convertedPledgedAmount)
    self.projectCurrency = try values.decode(String.self, forKey: .currency)
    self.userCurrency = try values.decodeIfPresent(String.self, forKey: .currentCurrency)
    self.userCurrencyRate = try values.decodeIfPresent(Float.self, forKey: .currentCurrencyRate)
    self.goal = try values.decode(Int.self, forKey: .goal)
    let value = try values.decode(Double.self, forKey: .pledged)
    self.pledged = Int(value)
    self.staticUsdRate = try values.decodeIfPresent(Float.self, forKey: .staticUsdRate) ?? 1.0
    self.updatesCount = try values.decodeIfPresent(Int.self, forKey: .updatesCount)
    self.usdExchangeRate = try values.decodeIfPresent(Float.self, forKey: .usdExchangeRate)
  }
}

extension Project.MemberData: Decodable {
  enum CodingKeys: String, CodingKey {
    case lastUpdatePublishedAt = "last_update_published_at"
    case permissions
    case unreadMessagesCount = "unread_messages_count"
    case unseenActivityCount = "unseen_activity_count"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.lastUpdatePublishedAt = try values.decodeIfPresent(TimeInterval.self, forKey: .lastUpdatePublishedAt)
    self
      .permissions = removeUnknowns(try values.decodeIfPresent([Permission].self, forKey: .permissions) ?? [])
    self.unreadMessagesCount = try values.decodeIfPresent(Int.self, forKey: .unreadMessagesCount)
    self.unseenActivityCount = try values.decodeIfPresent(Int.self, forKey: .unseenActivityCount)
  }
}

extension Project.Dates: Decodable {
  enum CodingKeys: String, CodingKey {
    case deadline
    case featuredAt = "featured_at"
    case finalCollectionDate = "final_collection_date"
    case launchedAt = "launched_at"
    case stateChangedAt = "state_changed_at"
  }
}

extension Project.Personalization: Decodable {
  enum CodingKeys: String, CodingKey {
    case backing
    case friends
    case isBacking = "is_backing"
    case isStarred = "is_starred"
  }
}

extension Project.RewardData: Decodable {
  enum CodingKeys: String, CodingKey {
    case addOns = "add_ons"
    case rewards
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.addOns = try values.decodeIfPresent([Reward].self, forKey: .addOns)
    self.rewards = try values.decodeIfPresent([Reward].self, forKey: .rewards) ?? []
  }
}

extension Project.Category: Decodable {
  enum CodingKeys: String, CodingKey {
    case analyticsName = "analytics_name"
    case id
    case name
    case parentId = "parent_id"
    case parentName = "parent_name"
  }
}

extension Project.Photo: Decodable {
  enum CodingKeys: String, CodingKey {
    case full
    case med
    case size1024x768 = "1024x768"
    case size1024x576 = "1024x576"
    case small
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.full = try values.decode(String.self, forKey: .full)
    self.med = try values.decode(String.self, forKey: .med)
    self.size1024x768 = try values
      .decodeIfPresent(String.self, forKey: .size1024x768) ??
      (try values.decodeIfPresent(String.self, forKey: .size1024x576))
    self.small = try values.decode(String.self, forKey: .small)
  }
}

extension Project.MemberData.Permission: Decodable {
  public init(from decoder: Decoder) throws {
    self = try Project.MemberData
      .Permission(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }
}

private func removeUnknowns(_ xs: [Project.MemberData.Permission]) -> [Project.MemberData.Permission] {
  return xs.filter { $0 != .unknown }
}

extension Project: GraphIDBridging {
  public static var modelName: String {
    return "Project"
  }
}

extension Project.Video: Decodable {}

extension Project {
  public var pledgeManagementAvailable: Bool {
    let isBacking = self.personalizationIsBacking ?? false
    let lastWaveActive = self.lastWave?.active ?? false
    let pmAcceptsNewBackers = self.pledgeManager?.acceptsNewBackers ?? false

    return lastWaveActive && (pmAcceptsNewBackers || isBacking)
  }
}
