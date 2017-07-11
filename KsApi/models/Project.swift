import Argo
import Curry
import Runes
import Prelude

public struct Project {
  public let blurb: String
  public let category: Category
  public let country: Country
  public let creator: User
  public let memberData: MemberData
  public let dates: Dates
  public let id: Int
  public let location: Location
  public let name: String
  public let personalization: Personalization
  public let photo: Photo
  public let rewards: [Reward]
  public let slug: String
  public let state: State
  public let stats: Stats
  public let urls: UrlsEnvelope
  public let video: Video?

  public struct UrlsEnvelope {
    public let web: WebEnvelope

    public struct WebEnvelope {
      public let project: String
      public let updates: String?
    }
  }

  public struct Video {
    public let id: Int
    public let high: String
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
    public let backersCount: Int
    public let commentsCount: Int?
    public let goal: Int
    public let pledged: Int
    public let staticUsdRate: Float
    public let updatesCount: Int?

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
  }

  public struct MemberData {
    public let lastUpdatePublishedAt: TimeInterval?
    public let permissions: [Permission]
    public let unreadMessagesCount: Int?
    public let unseenActivityCount: Int?

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
    public let deadline: TimeInterval
    public let featuredAt: TimeInterval?
    public let launchedAt: TimeInterval
    public let potdAt: TimeInterval?
    public let stateChangedAt: TimeInterval
  }

  public struct Personalization {
    public let backing: Backing?
    public let friends: [User]?
    public let isBacking: Bool?
    public let isStarred: Bool?
  }

  public struct Photo {
    public let full: String
    public let med: String
    public let size1024x768: String?
    public let small: String
  }

  public func endsIn48Hours(today: Date = Date()) -> Bool {
    let twoDays: TimeInterval = 60.0 * 60.0 * 48.0
    return self.dates.deadline - today.timeIntervalSince1970 <= twoDays
  }

  public func isFeaturedToday(today: Date = Date(), calendar: Calendar = .current) -> Bool {
    guard let featuredAt = self.dates.featuredAt else { return false }
    return isDateToday(date: featuredAt, today: today, calendar: calendar)
  }

  public func isPotdToday(today: Date = Date(), calendar: Calendar = .current) -> Bool {
    guard let potdAt = self.dates.potdAt else { return false }
    return isDateToday(date: potdAt, today: today, calendar: calendar)
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
    let create = curry(Project.init)
    let tmp1 = create
      <^> json <| "blurb"
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
      <*> (json <|| "rewards" <|> .success([]))
      <*> json <| "slug"
    return tmp3
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
    let create = curry(Project.Stats.init)
    return create
      <^> json <| "backers_count"
      <*> json <|? "comments_count"
      <*> json <| "goal"
      <*> json <| "pledged"
      <*> (json <| "static_usd_rate" <|> .success(1.0))
      <*> json <|? "updates_count"
  }
}

extension Project.MemberData: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.MemberData> {
    let create = curry(Project.MemberData.init)
    return create
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
      <*> json <|? "potd_at"
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
    let create = curry(Project.Photo.init)

    let url1024: Decoded<String?> = ((json <| "1024x768") <|> (json <| "1024x576"))
      // swiftlint:disable:next syntactic_sugar
      .map(Optional<String>.init)
      <|> .success(nil)

    return create
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
