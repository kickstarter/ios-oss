import Argo
import Curry
import Runes
import Prelude

public struct Project {

  public private(set) var blurb: String
  public private(set) var category: Category
  public private(set) var country: Country
  public private(set) var creator: User
  public private(set) var memberData: MemberData
  public private(set) var dates: Dates
  public private(set) var id: Int
  public private(set) var location: Location
  public private(set) var name: String
  public private(set) var personalization: Personalization
  public private(set) var photo: Photo
  public private(set) var rewards: [Reward]
  public private(set) var slug: String
  public private(set) var staffPick: Bool
  public private(set) var state: State
  public private(set) var stats: Stats
  public private(set) var urls: UrlsEnvelope
  public private(set) var video: Video?

  public struct UrlsEnvelope {
    public private(set) var web: WebEnvelope

    public struct WebEnvelope {
      public private(set) var project: String
      public private(set) var updates: String?
    }
  }

  public struct Video {
    public private(set) var id: Int
    public private(set) var high: String
    public private(set) var hls: String?
  }

  public enum State: String, Argo.Decodable {
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
    public private(set) var backersCount: Int
    public private(set) var commentsCount: Int?
    /// The currency code of the project ex. USD
    public private(set) var currency: String
    /// The currency code of the User's preferred currency ex. SEK
    public private(set) var currentCurrency: String?
    /// The currency conversion rate between the User's preferred currency
    /// and the Project's currency
    public private(set) var currentCurrencyRate: Float?
    public private(set) var goal: Int
    public private(set) var pledged: Int
    public private(set) var staticUsdRate: Float
    public private(set) var updatesCount: Int?

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

    /// Pledged amount converted to current currency.
    public var pledgedCurrentCurrency: Int? {
      return self.currentCurrencyRate.map { Int(floor(Float(self.pledged) * $0)) }
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
  }

  public struct MemberData {
    public private(set) var lastUpdatePublishedAt: TimeInterval?
    public private(set) var permissions: [Permission]
    public private(set) var unreadMessagesCount: Int?
    public private(set) var unseenActivityCount: Int?

    public enum Permission: String {
      case editProject = "edit_project"
      case editFaq = "edit_faq"
      case post = "post"
      case comment = "comment"
      case viewPledges = "view_pledges"
      case fulfillment = "fulfillment"
      case unknown = "unknown"
    }
  }

  public struct Dates {
    public private(set) var deadline: TimeInterval
    public private(set) var featuredAt: TimeInterval?
    public private(set) var launchedAt: TimeInterval
    public private(set) var stateChangedAt: TimeInterval
  }

  public struct Personalization {
    public private(set) var backing: Backing?
    public private(set) var friends: [User]?
    public private(set) var isBacking: Bool?
    public private(set) var isStarred: Bool?
  }

  public struct Photo {
    public private(set) var full: String
    public private(set) var med: String
    public private(set) var size1024x768: String?
    public private(set) var small: String
  }

  public func endsIn48Hours(today: Date = Date()) -> Bool {
    let twoDays: TimeInterval = 60.0 * 60.0 * 48.0
    return self.dates.deadline - today.timeIntervalSince1970 <= twoDays
  }

  public func isFeaturedToday(today: Date = Date(), calendar: Calendar = .current) -> Bool {
    guard let featuredAt = self.dates.featuredAt else { return false }
    return isDateToday(date: featuredAt, today: today, calendar: calendar)
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
  static public func decode(_ json: JSON) -> Decoded<Project> {
    let tmp1 = curry(Project.init)
      <^> json <| "blurb"
      <*> ((json <| "category" >>- decodeToGraphCategory) as Decoded<Category>)
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
  static public func decode(_ json: JSON) -> Decoded<Project.UrlsEnvelope> {
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

extension Project.Photo: Argo.Decodable {
  static public func decode(_ json: JSON) -> Decoded<Project.Photo> {

    let url1024: Decoded<String?> = ((json <| "1024x768") <|> (json <| "1024x576"))
      // swiftlint:disable:next syntactic_sugar
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
    if case .string(let permission) = json {
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

/*
 This is a helper function that extracts the value from the Argo.JSON object type to create a graph Category
 object (that conforms to Swift.Decodable). It's an work around that fixes the problem of incompatibility
 between Swift.Decodable and Argo.Decodable protocols and will be deleted in the future when we update our
 code to use exclusively Swift's native Decodable.
 */
private func decodeToGraphCategory(_ json: JSON?) -> Decoded<Category> {

  guard let jsonObj = json else {
    return .success(Category(id: "-1", name: "Unknown Category"))
  }

  switch jsonObj {
  case .object(let dic):
    let category = Category(id: categoryInfo(dic).0,
                            name: categoryInfo(dic).1,
                            parentId: categoryInfo(dic).2)
    return .success(category)
  default:
    return .failure(DecodeError.custom("JSON should be object type"))
  }
}

private func categoryInfo(_ json: [String: JSON]) -> (String, String, String?) {

  guard let name = json["name"], let id = json["id"] else {
    return("", "", nil)
  }
  let parentId = json["parent_id"]

  switch (id, name, parentId) {
  case (.number(let id), .string(let name), .number(let parentId)?):
    return ("\(id)", name, "\(parentId)")
  case (.number(let id), .string(let name), nil):
    return ("\(id)", name, nil)
  default:
    return("", "", nil)
  }
}

extension Project: GraphIDBridging {
  public static var modelName: String {
    return "Project"
  }
}
