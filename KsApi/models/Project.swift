import Argo
import Curry
import Prelude
import Runes

public struct Project {
  public var availableCardTypes: [String]?
  public var blurb: String
  public var category: Category
  public var country: Country
  public var creator: User
  public var memberData: MemberData
  public var dates: Dates
  public var id: Int
  public var location: Location
  public var name: String
  public var personalization: Personalization
  public var photo: Photo
  public var prelaunchActivated: Bool?
  public var rewards: [Reward]
  public var slug: String
  public var staffPick: Bool
  public var state: State
  public var stats: Stats
  public var urls: UrlsEnvelope
  public var video: Video?

  public struct Category {
    public var id: Int
    public var name: String
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

  public enum State: String, Argo.Decodable, CaseIterable {
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
    public var convertedPledgedAmount: Int?
    /// The currency code of the project ex. USD
    public var currency: String
    /// The currency code of the User's preferred currency ex. SEK
    public var currentCurrency: String?
    /// The currency conversion rate between the User's preferred currency
    /// and the Project's currency
    public var currentCurrencyRate: Float?
    public var goal: Int
    public var pledged: Int
    public var staticUsdRate: Float
    public var updatesCount: Int?

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
    public var pledgedUsd: Int {
      return Int(floor(Float(self.pledged) * self.staticUsdRate))
    }

    /// Goal amount converted to USD.
    public var goalUsd: Int {
      return Int(floor(Float(self.goal) * self.staticUsdRate))
    }

    /// Goal amount converted to current currency.
    public var goalCurrentCurrency: Int? {
      return self.currentCurrencyRate.map { Int(floor(Float(self.goal) * $0)) }
    }

    /// Country determined by current currency.
    public var currentCountry: Project.Country? {
      guard let currentCurrency = self.currentCurrency else {
        return nil
      }

      return Project.Country(currencyCode: currentCurrency)
    }

    /// Omit US currency code
    public var omitUSCurrencyCode: Bool {
      let currentCurrency = self.currentCurrency ?? Project.Country.us.currencyCode

      return currentCurrency == Project.Country.us.currencyCode
    }

    /// Project pledge & goal values need conversion
    public var needsConversion: Bool {
      let currentCurrency = self.currentCurrency ?? Project.Country.us.currencyCode

      return self.currency != currentCurrency
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
    public var deadline: TimeInterval
    public var featuredAt: TimeInterval?
    public var launchedAt: TimeInterval
    public var stateChangedAt: TimeInterval

    /**
     Returns project duration in Days
     */
    public func duration(using calendar: Calendar = .current) -> Int? {
      let deadlineDate = Date(timeIntervalSince1970: self.deadline)
      let launchedAtDate = Date(timeIntervalSince1970: self.launchedAt)

      return calendar.dateComponents([.day], from: launchedAtDate, to: deadlineDate).day
    }

    public func hoursRemaining(from date: Date = Date(), using calendar: Calendar = .current) -> Int? {
      let deadlineDate = Date(timeIntervalSince1970: self.deadline)

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

  public func endsIn48Hours(today: Date = Date()) -> Bool {
    let twoDays: TimeInterval = 60.0 * 60.0 * 48.0
    return self.dates.deadline - today.timeIntervalSince1970 <= twoDays
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

extension Project: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project> {
    let tmp1 = curry(Project.init)
      <^> json <||? "available_card_types"
      <*> json <| "blurb"
      <*> json <| "category"
      <*> Project.Country.decode(json)
      <*> json <| "creator"
    let tmp2 = tmp1
      <*> Project.MemberData.decode(json)
      <*> Project.Dates.decode(json)
      <*> json <| "id"
      <*> (json <| "location" <|> .success(Location.none))
    let tmp3 = tmp2
      <*> json <| "name"
      <*> Project.Personalization.decode(json)
      <*> json <| "photo"
      <*> json <|? "prelaunch_activated"
      <*> (json <|| "rewards" <|> .success([]))
      <*> json <| "slug"
    return tmp3
      <*> json <| "staff_pick"
      <*> json <| "state"
      <*> Project.Stats.decode(json)
      <*> json <| "urls"
      <*> json <|? "video"
  }
}

extension Project.UrlsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.UrlsEnvelope> {
    return curry(Project.UrlsEnvelope.init)
      <^> json <| "web"
  }
}

extension Project.UrlsEnvelope.WebEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.UrlsEnvelope.WebEnvelope> {
    return curry(Project.UrlsEnvelope.WebEnvelope.init)
      <^> json <| "project"
      <*> json <|? "updates"
  }
}

extension Project.Stats: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.Stats> {
    let tmp1 = curry(Project.Stats.init)
      <^> json <| "backers_count"
      <*> json <|? "comments_count"
      <*> json <|? "converted_pledged_amount"
      <*> json <| "currency"
      <*> json <|? "current_currency"
      <*> json <|? "fx_rate"
    return tmp1
      <*> json <| "goal"
      <*> json <| "pledged"
      <*> (json <| "static_usd_rate" <|> .success(1.0))
      <*> json <|? "updates_count"
  }
}

extension Project.MemberData: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.MemberData> {
    return curry(Project.MemberData.init)
      <^> json <|? "last_update_published_at"
      <*> (removeUnknowns <^> (json <|| "permissions") <|> .success([]))
      <*> json <|? "unread_messages_count"
      <*> json <|? "unseen_activity_count"
  }
}

extension Project.Dates: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.Dates> {
    return curry(Project.Dates.init)
      <^> json <| "deadline"
      <*> json <|? "featured_at"
      <*> json <| "launched_at"
      <*> json <| "state_changed_at"
  }
}

extension Project.Personalization: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.Personalization> {
    return curry(Project.Personalization.init)
      <^> json <|? "backing"
      <*> json <||? "friends"
      <*> json <|? "is_backing"
      <*> json <|? "is_starred"
  }
}

extension Project.Category: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.Category> {
    return curry(Project.Category.init)
      <^> json <| "id"
      <*> json <| "name"
      <*> json <|? "parent_id"
      <*> json <|? "parent_name"
  }
}

extension Project.Photo: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.Photo> {
    let url1024: Decoded<String?> = ((json <| "1024x768") <|> (json <| "1024x576"))
      .map(Optional<String>.init)
      <|> .success(nil)

    return curry(Project.Photo.init)
      <^> json <| "full"
      <*> json <| "med"
      <*> url1024
      <*> json <| "small"
  }
}

extension Project.MemberData.Permission: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.MemberData.Permission> {
    if case let .string(permission) = json {
      return self.init(rawValue: permission).map(pure) ?? .success(.unknown)
    }
    return .success(.unknown)
  }
}

private func removeUnknowns(_ xs: [Project.MemberData.Permission]) -> [Project.MemberData.Permission] {
  return xs.filter { $0 != .unknown }
}

private func toInt(string: String) -> Decoded<Int> {
  return Int(string).map(Decoded.success)
    ?? Decoded.failure(DecodeError.custom("Couldn't decoded \"\(string)\" into Int."))
}

extension Project: GraphIDBridging {
  public static var modelName: String {
    return "Project"
  }
}
