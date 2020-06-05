import Argo
import KsApi
import Runes

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
  case emailBackerFailedTransaction
  case messageThread
  case onboarding
  case profile
  case profileBacked
  case profileSaved
  case projectCollection(DiscoveryParams.TagID)
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
  public init(code: String) {
    switch code {
    case "activity": self = .activity
    case "category": self = .category
    case "category_featured": self = .categoryFeatured
    case "discovery_activity_sample": self = .activitySample
    case "category_ending_soon": self = .categoryWithSort(.endingSoon)
    case "category_home": self = .categoryWithSort(.magic)
    case "category_newest": self = .categoryWithSort(.newest)
    case "category_popular": self = .categoryWithSort(.popular)
    case "city": self = .city
    case "dashboard": self = .dashboard
    case "dashboard_activity": self = .dashboardActivity
    case "discovery": self = .discovery
    case "discovery_ending_soon": self = .discoveryWithSort(.endingSoon)
    case "discovery_home": self = .discoveryWithSort(.magic)
    case "discovery_newest": self = .discoveryWithSort(.newest)
    case "discovery_popular": self = .discoveryWithSort(.popular)
    case "ksr_email_backer_failed_transaction": self = .emailBackerFailedTransaction
    case "ios_experiment_onboarding_1": self = .onboarding
    case "message_thread": self = .messageThread
    case "profile": self = .profile
    case "profile_backed": self = .profileBacked
    case "profile_saved": self = .profileSaved
    case "project_page": self = .projectPage
    case "push": self = .push
    case "recommended": self = .recommended
    case "recommended_ending_soon": self = .recommendedWithSort(.endingSoon)
    case "recommended_home": self = .recommendedWithSort(.magic)
    case "recommended_newest": self = .recommendedWithSort(.newest)
    case "recommended_popular": self = .recommendedWithSort(.popular)
    case "recs_ending_soon": self = .recsWithSort(.endingSoon)
    case "recs_home": self = .recsWithSort(.magic)
    case "recs_newest": self = .recsWithSort(.newest)
    case "recs_popular": self = .recsWithSort(.popular)
    case "search": self = .search
    case "search_featured": self = .searchFeatured
    case "search_popular": self = .searchPopular
    case "search_popular_featured": self = .searchPopularFeatured
    case "social": self = .social
    case "social_ending_soon": self = .socialWithSort(.endingSoon)
    case "social_home": self = .socialWithSort(.magic)
    case "social_newest": self = .socialWithSort(.newest)
    case "social_popular": self = .socialWithSort(.popular)
    case "starred_ending_soon": self = .starredWithSort(.endingSoon)
    case "starred_home": self = .starredWithSort(.magic)
    case "starred_newest": self = .starredWithSort(.newest)
    case "starred_popular": self = .starredWithSort(.popular)
    case "thanks": self = .thanks
    case "update": self = .update
    default: self = .unrecognized(code)
    }
  }

  /// A string representation of the ref tag that can be used in analytics tracking, cookies, etc...
  public var stringTag: String {
    switch self {
    case .activity:
      return "activity"
    case .activitySample:
      return "discovery_activity_sample"
    case .category:
      return "category"
    case .categoryFeatured:
      return "category_featured"
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
    case .emailBackerFailedTransaction:
      return "ksr_email_backer_failed_transaction"
    case .messageThread:
      return "message_thread"
    case .onboarding:
      return "ios_experiment_onboarding_1"
    case .profile:
      return "profile"
    case .profileBacked:
      return "profile_backed"
    case let .projectCollection(tagId):
      return "ios_project_collection_tag_\(tagId.rawValue)"
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

extension RefTag: Equatable {}
extension RefTag: CustomStringConvertible {
  public var description: String {
    return self.stringTag
  }
}

extension RefTag: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.stringTag)
  }
}

private func sortRefTagSuffix(_ sort: DiscoveryParams.Sort) -> String {
  switch sort {
  case .endingSoon:
    return "_ending_soon"
  case .magic:
    return "_home"
  case .newest:
    return "_newest"
  case .popular:
    return "_popular"
  case .distance:
    return "_distance"
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

extension RefTag {
  public static func fromParams(_ params: DiscoveryParams) -> RefTag {
    if let tagId = params.tagId {
      return .projectCollection(tagId)
    }

    if params.category != nil {
      return .categoryWithSort(params.sort ?? .magic)
    } else if params.recommended == .some(true) {
      return .recsWithSort(params.sort ?? .magic)
    } else if params.staffPicks == .some(true) {
      return .recommendedWithSort(params.sort ?? .magic)
    } else if params.social == .some(true) {
      return .socialWithSort(params.sort ?? .magic)
    } else if params.starred == .some(true) {
      return .starredWithSort(params.sort ?? .magic)
    }

    return RefTag.discoveryWithSort(params.sort ?? .magic)
  }
}
