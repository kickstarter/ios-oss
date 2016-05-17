import KsApi

// swiftlint:disable type_name
public enum RefTag {
  case activity
  case activitySample
  case category
  case categoryFeatured
  case categoryWithSort(DiscoveryParams.Sort)
  case city
  case discovery
  case discoveryPotd
  case recommended
  case recommendedWithSort(DiscoveryParams.Sort)
  case search
  case social
  case thanks
  case unrecognized(String)
  case users

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
    case "category_ending_soon":      self = .categoryWithSort(.EndingSoon)
    case "category":                  self = .categoryWithSort(.Magic)
    case "category_most_funded":      self = .categoryWithSort(.MostFunded)
    case "category_newest":           self = .categoryWithSort(.Newest)
    case "category_popular":          self = .categoryWithSort(.Popular)
    case "city":                      self = .city
    case "discovery":                 self = .discovery
    case "discovery_potd":            self = .discoveryPotd
    case "recommended":               self = .recommended
    case "recommended_ending_soon":   self = .recommendedWithSort(.EndingSoon)
    case "recommended":               self = .recommendedWithSort(.Magic)
    case "recommended_most_funded":   self = .recommendedWithSort(.MostFunded)
    case "recommended_newest":        self = .recommendedWithSort(.Newest)
    case "recommended_popular":       self = .recommendedWithSort(.Popular)
    case "search":                    self = .search
    case "social":                    self = .social
    case "thanks":                    self = .thanks
    case "users":                     self = .users
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
    case .discovery:
      return "discovery"
    case .discoveryPotd:
      return "discovery_potd"
    case .recommended:
      return "recommended"
    case let .recommendedWithSort(sort):
      return "recommended" + sortRefTagSuffix(sort)
    case .search:
      return "search"
    case .social:
      return "social"
    case .thanks:
      return "thanks"
    case .users:
      return "users"
    case let .unrecognized(code):
      return code
    }
  }
}

extension RefTag: Equatable {
}
public func == (lhs: RefTag, rhs: RefTag) -> Bool {
  switch (lhs, rhs) {
  case (.activity, .activity), (.category, .category), (.categoryFeatured, .categoryFeatured),
    (.activitySample, .activitySample), (.city, .city), (.discovery, .discovery),
    (.discoveryPotd, .discoveryPotd), (.recommended, .recommended), (.search, .search),
    (.social, .social), (.thanks, .thanks), (.users, .users):
    return true
  case let (.categoryWithSort(lhs), .categoryWithSort(rhs)):
    return lhs == rhs
  case let (.recommendedWithSort(lhs), .recommendedWithSort(rhs)):
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

private func sortRefTagSuffix(sort: DiscoveryParams.Sort) -> String {
  switch sort {
  case .EndingSoon:
    return "_ending_soon"
  case .Magic:
    return ""
  case .MostFunded:
    return "_most_funded"
  case .Newest:
    return "_newest"
  case .Popular:
    return "_popular"
  }
}
