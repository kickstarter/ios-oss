import Argo
import Runes
import KsApi

//case countdown
//case liveStreamDiscovery
//case projectPage
//case pushNotification

public enum RefTag {
  case activity
  case activitySample
  case category
  case categoryFeatured
  case categoryWithSort(DiscoveryParams.Sort)
  case city
  case dashboard
  case dashboardActivity
  case discovery
  case discoveryPotd
  case discoveryWithSort(DiscoveryParams.Sort)
  case liveStreamCountdown
  case liveStreamDiscovery
  case messageThread
  case profileBacked
  case projectPage
  case push
  case recommended
  case recommendedWithSort(DiscoveryParams.Sort)
  case recsWithSort(DiscoveryParams.Sort)
  case search
  case social
  case socialWithSort(DiscoveryParams.Sort)
  case starredWithSort(DiscoveryParams.Sort)
  case thanks
  case unrecognized(String)
  case update

  /**
   Create a RefTag value from a code string. If a ref tag cannot be matched, an `.unrecognized` tag is
   returned.

   - parameter code: A code string.

   - returns: A ref tag.
   */
  // swiftlint:disable function_body_length
  // swiftlint:disable cyclomatic_complexity
  public init(code: String) {
    switch code {
    case "activity":                  self = .activity
    case "category":                  self = .category
    case "category_featured":         self = .categoryFeatured
    case "discovery_activity_sample": self = .activitySample
    case "category_ending_soon":      self = .categoryWithSort(.endingSoon)
    case "category_home":             self = .categoryWithSort(.magic)
    case "category_most_funded":      self = .categoryWithSort(.mostFunded)
    case "category_newest":           self = .categoryWithSort(.newest)
    case "category_popular":          self = .categoryWithSort(.popular)
    case "city":                      self = .city
    case "dashboard":                 self = .dashboard
    case "dashboard_activity":        self = .dashboardActivity
    case "discovery":                 self = .discovery
    case "discovery_ending_soon":     self = .discoveryWithSort(.endingSoon)
    case "discovery_home":            self = .discoveryWithSort(.magic)
    case "discovery_most_funded":     self = .discoveryWithSort(.mostFunded)
    case "discovery_newest":          self = .discoveryWithSort(.newest)
    case "discovery_popular":         self = .discoveryWithSort(.popular)
    case "discovery_potd":            self = .discoveryPotd
    case "live_stream_countdown":     self = .liveStreamCountdown
    case "live_stream_discovery":     self = .liveStreamDiscovery
    case "message_thread":            self = .messageThread
    case "profile_backed":            self = .profileBacked
    case "project_page":              self = .projectPage
    case "push":                      self = .push
    case "recommended":               self = .recommended
    case "recommended_ending_soon":   self = .recommendedWithSort(.endingSoon)
    case "recommended_home":          self = .recommendedWithSort(.magic)
    case "recommended_most_funded":   self = .recommendedWithSort(.mostFunded)
    case "recommended_newest":        self = .recommendedWithSort(.newest)
    case "recommended_popular":       self = .recommendedWithSort(.popular)
    case "recs_ending_soon":          self = .recsWithSort(.endingSoon)
    case "recs_home":                 self = .recsWithSort(.magic)
    case "recs_most_funded":          self = .recsWithSort(.mostFunded)
    case "recs_newest":               self = .recsWithSort(.newest)
    case "recs_popular":              self = .recsWithSort(.popular)
    case "search":                    self = .search
    case "social":                    self = .social
    case "social_ending_soon":        self = .socialWithSort(.endingSoon)
    case "social_home":               self = .socialWithSort(.magic)
    case "social_most_funded":        self = .socialWithSort(.mostFunded)
    case "social_newest":             self = .socialWithSort(.newest)
    case "social_popular":            self = .socialWithSort(.popular)
    case "starred_ending_soon":       self = .starredWithSort(.endingSoon)
    case "starred_home":              self = .starredWithSort(.magic)
    case "starred_most_funded":       self = .starredWithSort(.mostFunded)
    case "starred_newest":            self = .starredWithSort(.newest)
    case "starred_popular":           self = .starredWithSort(.popular)
    case "thanks":                    self = .thanks
    case "update":                    self = .update
    default:                          self = .unrecognized(code)
    }
  }
  // swiftlint:enable cyclomatic_complexity
  // swiftlint:enable function_body_length

  /// A string representation of the ref tag that can be used in analytics tracking, cookies, etc...
  public var stringTag: String {
    switch self {
    case .activity:
      return "activity"
    case .category:
      return "category"
    case .categoryFeatured:
      return "category_featured"
    case .activitySample:
      return "discovery_activity_sample"
    case let .categoryWithSort(sort):
      return "category" + sortRefTagSuffix(sort)
    case .city:
      return "city"
    case .dashboard:
      return "dashboard"
    case .dashboardActivity:
      return "dashboard_activity"
    case .discovery:
      return "discovery"
    case .discoveryPotd:
      return "discovery_potd"
    case let .discoveryWithSort(sort):
      return "discovery" + sortRefTagSuffix(sort)
    case .liveStreamCountdown:
      return "live_stream_countdown"
    case .liveStreamDiscovery:
      return "live_stream_discovery"
    case .messageThread:
      return "message_thread"
    case .profileBacked:
      return "profile_backed"
    case .projectPage:
      return "project_page"
    case .push:
      return "push"
    case .recommended:
      return "recommended"
    case let .recommendedWithSort(sort):
      return "recommended" + sortRefTagSuffix(sort)
    case let .recsWithSort(sort):
      return "recs" + sortRefTagSuffix(sort)
    case .search:
      return "search"
    case .social:
      return "social"
    case let .socialWithSort(sort):
      return "social" + sortRefTagSuffix(sort)
    case let .starredWithSort(sort):
      return "starred" + sortRefTagSuffix(sort)
    case .thanks:
      return "thanks"
    case let .unrecognized(code):
      return code
    case .update:
      return "update"
    }
  }
}

extension RefTag: Equatable {
}
public func == (lhs: RefTag, rhs: RefTag) -> Bool {
  switch (lhs, rhs) {
  case (.activity, .activity), (.category, .category), (.categoryFeatured, .categoryFeatured),
    (.activitySample, .activitySample), (.city, .city), (.dashboard, .dashboard),
    (.dashboardActivity, .dashboardActivity), (.discovery, .discovery), (.discoveryPotd, .discoveryPotd),
    (.liveStreamCountdown, .liveStreamCountdown), (.liveStreamDiscovery, .liveStreamDiscovery),
    (.messageThread, .messageThread), (.profileBacked, .profileBacked), (.projectPage, .projectPage),
    (.push, .push), (.recommended, .recommended), (.search, .search), (.social, .social), (.thanks, .thanks),
    (.update, .update):
    return true
  case let (.categoryWithSort(lhs), .categoryWithSort(rhs)):
    return lhs == rhs
  case let (.discoveryWithSort(lhs), .discoveryWithSort(rhs)):
    return lhs == rhs
  case let (.recommendedWithSort(lhs), .recommendedWithSort(rhs)):
    return lhs == rhs
  case let (.recsWithSort(lhs), .recsWithSort(rhs)):
    return lhs == rhs
  case let (.socialWithSort(lhs), .socialWithSort(rhs)):
    return lhs == rhs
  case let (.starredWithSort(lhs), .starredWithSort(rhs)):
    return lhs == rhs
  case let (.unrecognized(lhs), .unrecognized(rhs)):
    return lhs == rhs
  default:
    return false
  }
}

extension RefTag: CustomStringConvertible {
  public var description: String {
    return self.stringTag
  }
}

extension RefTag: Hashable {
  public var hashValue: Int {
    return self.stringTag.hashValue
  }
}

private func sortRefTagSuffix(_ sort: DiscoveryParams.Sort) -> String {
  switch sort {
  case .endingSoon:
    return "_ending_soon"
  case .magic:
    return "_home"
  case .mostFunded:
    return "_most_funded"
  case .newest:
    return "_newest"
  case .popular:
    return "_popular"
  }
}

extension RefTag: Decodable {
  public static func decode(_ json: JSON) -> Decoded<RefTag> {
    switch json {
    case let .string(code):
      return .success(RefTag(code: code))
    default:
      return .failure(.custom("RefTag code must be a string."))
    }
  }
}
