import Argo
import Runes
import KsApi

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
  case discoveryWithSort(DiscoveryParams.Sort)
  case liveStream
  case liveStreamCountdown
  case liveStreamDiscovery
  case liveStreamReplay
  case messageThread
  case profile
  case profileBacked
  case profileSaved
  case projectPage
  case push
  case recommended
  case recommendedWithSort(DiscoveryParams.Sort)
  case recsWithSort(DiscoveryParams.Sort)
  case search
  case searchFeatured
  case searchPopular
  case searchPopularFeatured
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
    case "live_stream":               self = .liveStream
    case "live_stream_countdown":     self = .liveStreamCountdown
    case "live_stream_discovery":     self = .liveStreamDiscovery
    case "live_stream_replay":        self = .liveStreamReplay
    case "message_thread":            self = .messageThread
    case "profile":                   self = .profile
    case "profile_backed":            self = .profileBacked
    case "profile_saved":             self = .profileSaved
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
    case "search_featured":           self = .searchFeatured
    case "search_popular":            self = .searchPopular
    case "search_popular_featured":   self = .searchPopularFeatured
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
    case let .discoveryWithSort(sort):
      return "discovery" + sortRefTagSuffix(sort)
    case .liveStream:
      return "live_stream"
    case .liveStreamCountdown:
      return "live_stream_countdown"
    case .liveStreamDiscovery:
      return "live_stream_discovery"
    case .liveStreamReplay:
      return "live_stream_replay"
    case .messageThread:
      return "message_thread"
    case .profile:
      return "profile"
    case .profileBacked:
      return "profile_backed"
    case .profileSaved:
      return "profile_saved"
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
    case .searchFeatured:
      return "search_featured"
    case .searchPopular:
      return "search_popular"
    case .searchPopularFeatured:
      return "search_popular_featured"
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
    (.dashboardActivity, .dashboardActivity), (.discovery, .discovery),
    (.liveStreamCountdown, .liveStreamCountdown), (.liveStreamDiscovery, .liveStreamDiscovery),
    (.liveStreamReplay, .liveStreamReplay), (.messageThread, .messageThread), (.profile, .profile),
    (.profileBacked, .profileBacked), (.profileSaved, .profileSaved), (.projectPage, .projectPage),
    (.push, .push), (.recommended, .recommended), (.search, .search), (.searchFeatured, .searchFeatured),
    (.searchPopular, .searchPopular), (.searchPopularFeatured, .searchPopularFeatured), (.social, .social),
    (.thanks, .thanks), (.update, .update):
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

extension RefTag: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<RefTag> {
    switch json {
    case let .string(code):
      return .success(RefTag(code: code))
    default:
      return .failure(.custom("RefTag code must be a string."))
    }
  }
}
