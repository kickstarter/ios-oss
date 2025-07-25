
import Prelude

public struct DiscoveryParams {
  public var backed: Bool?
  public var category: Category?
  public var collaborated: Bool?
  public var created: Bool?
  public var hasVideo: Bool?
  public var includePOTD: Bool?
  public var page: Int?
  public var perPage: Int?
  public var query: String?
  public var recommended: Bool?
  public var seed: Int?
  public var similarTo: Project?
  public var social: Bool?
  public var sort: Sort?
  public var staffPicks: Bool?
  public var starred: Bool?
  public var state: State?
  public var percentRaised: PercentRaisedBucket?
  public var location: Location?
  public var amountRaised: AmountRaisedBucket?
  public var goal: GoalBucket?

  public enum State: String, Decodable {
    case all
    case live
    case successful
    case late_pledge
    case upcoming
  }

  public enum Sort: String, Decodable {
    case endingSoon = "end_date"
    case magic
    case newest
    case popular = "popularity"
    case most_funded
    case most_backed

    public var trackingString: String {
      switch self {
      case .endingSoon: return "ending_soon"
      case .magic: return "magic"
      case .newest: return "newest"
      case .popular: return "popular"
      case .most_funded: return "most_funded"
      case .most_backed: return "most_backed"
      }
    }
  }

  public enum PercentRaisedBucket: Int, CaseIterable {
    /// 0 to 75%
    case bucket_0
    /// 75% - 100%
    case bucket_1
    /// 100% or more
    case bucket_2
  }

  public enum AmountRaisedBucket: Int, CaseIterable {
    /// Range from 0 to 1,000 USD
    case bucket_0

    /// Range from 1,000 to 10,000 USD
    case bucket_1

    /// Range from 10,000 to 100,000 USD
    case bucket_2

    /// Range from 100,000 to 1,000,000 USD
    case bucket_3

    /// Range from 1,000,000 to Infinity USD
    case bucket_4
  }

  public enum GoalBucket: Int, CaseIterable {
    /// Range from 0 to 1,000 USD
    case bucket_0

    /// Range from 1,000 to 10,000 USD
    case bucket_1

    /// Range from 10,000 to 100,000 USD
    case bucket_2

    /// Range from 100,000 to 1,000,000 USD
    case bucket_3

    /// Range from 1,000,000 to Infinity USD
    case bucket_4
  }

  public static let defaults = DiscoveryParams(
    backed: nil, category: nil, collaborated: nil,
    created: nil, hasVideo: nil, includePOTD: nil,
    page: nil, perPage: nil, query: nil, recommended: nil,
    seed: nil, similarTo: nil, social: nil, sort: nil,
    staffPicks: nil, starred: nil, state: nil
  )

  public static let recommendedDefaults = DiscoveryParams.defaults
    |> DiscoveryParams.lens.includePOTD .~ true
    |> DiscoveryParams.lens.backed .~ false
    |> DiscoveryParams.lens.recommended .~ true

  public var queryParams: [String: String] {
    var params: [String: String] = [:]
    params["backed"] = self.backed == true ? "1" : self.backed == false ? "-1" : nil
    params["category_id"] = self.category?.intID?.description
    params["collaborated"] = self.collaborated?.description
    params["created"] = self.created?.description
    params["has_video"] = self.hasVideo?.description
    params["page"] = self.page?.description
    params["per_page"] = self.perPage?.description
    params["recommended"] = self.recommended?.description
    params["seed"] = self.seed?.description
    params["similar_to"] = self.similarTo?.id.description
    params["social"] = self.social == true ? "1" : self.social == false ? "-1" : nil
    params["sort"] = self.sort?.rawValue
    params["staff_picks"] = self.staffPicks?.description
    params["starred"] = self.starred == true ? "1" : self.starred == false ? "-1" : nil
    params["state"] = self.state?.rawValue
    params["term"] = self.query

    return params
  }
}

extension DiscoveryParams: Equatable {}
public func == (a: DiscoveryParams, b: DiscoveryParams) -> Bool {
  return a.queryParams == b.queryParams
}

extension DiscoveryParams: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.description)
  }
}

extension DiscoveryParams: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    return self.queryParams.description
  }

  public var debugDescription: String {
    return self.queryParams.debugDescription
  }
}

extension DiscoveryParams: Decodable {
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.backed = try stringIntToBool(values.decodeIfPresent(String.self, forKey: .backed))
    self.category = try values.decodeIfPresent(Category.self, forKey: .category)
    self.collaborated = try stringToBool(values.decodeIfPresent(String.self, forKey: .collaborated))
    self.created = try stringToBool(values.decodeIfPresent(String.self, forKey: .created))
    self.hasVideo = try stringToBool(values.decodeIfPresent(String.self, forKey: .hasVideo))
    self.includePOTD = try stringToBool(values.decodeIfPresent(String.self, forKey: .includePOTD))
    self.page = try values.decodeIfPresent(String.self, forKey: .page).flatMap { Int($0) }
    self.perPage = try values.decodeIfPresent(String.self, forKey: .perPage).flatMap { Int($0) }
    self.query = try values.decodeIfPresent(String.self, forKey: .query)
    self.recommended = try stringToBool(values.decodeIfPresent(String.self, forKey: .recommended))
    self.seed = try values.decodeIfPresent(String.self, forKey: .seed).flatMap { Int($0) }
    self.similarTo = try values.decodeIfPresent(Project.self, forKey: .similarTo)
    self.social = try stringIntToBool(values.decodeIfPresent(String.self, forKey: .social))
    self.sort = try values.decodeIfPresent(Sort.self, forKey: .sort)
    self.staffPicks = try stringToBool(values.decodeIfPresent(String.self, forKey: .staffPicks))
    self.starred = try stringIntToBool(values.decodeIfPresent(String.self, forKey: .starred))
    self.state = try values.decodeIfPresent(State.self, forKey: .state)
  }

  enum CodingKeys: String, CodingKey {
    case backed
    case category
    case collaborated
    case created
    case hasVideo = "has_video"
    case includePOTD = "include_potd"
    case page
    case perPage = "per_page"
    case query = "term"
    case recommended
    case seed
    case similarTo = "similar_to"
    case social
    case sort
    case staffPicks = "staff_picks"
    case starred
    case state
  }
}

private func stringToBool(_ string: String?) -> Bool? {
  guard let string = string else { return nil }
  switch string {
  // taken from server's `value_to_boolean` function
  case "true", "1", "t", "T", "TRUE", "on", "ON":
    return true
  case "false", "0", "f", "F", "FALSE", "off", "OFF":
    return false
  default:
    return nil
  }
}

private func stringIntToBool(_ string: String?) -> Bool? {
  guard let string = string else { return nil }
  return Int(string)
    .filter { $0 <= 1 && $0 >= -1 }
    .flatMap { ($0 == 0) ? nil : ($0 == 1) }
}

extension DiscoveryParams {
  /// We're using `DiscoveryParams` in two places: Discover, which is powered by API V1,
  /// and Search, which is now powered by GraphQL (using the `projects` query; see `SearchQuery.graphql`).
  /// Search uses `DiscoveryParams` because our Search analytics is tightly coupled with `DiscoveryParams`,
  /// and we haven't had the chance to fix that yet.
  ///
  /// This function validates that the params are only using enum values which are available in API V1, _not_ values
  /// which were added for Search/GraphQL support.

  func validForAPIV1() -> Bool {
    if let sort = self.sort {
      switch sort {
      case .endingSoon:
        break
      case .magic:
        break
      case .newest:
        break
      case .popular:
        break
      case .most_funded:
        return false
      case .most_backed:
        return false
      }
    }

    if let state = self.state {
      switch state {
      case .all:
        break
      case .live:
        break
      case .successful:
        break
      case .late_pledge:
        return false
      case .upcoming:
        return false
      }
    }

    if let _ = self.percentRaised {
      return false
    }

    if let _ = self.location {
      return false
    }

    if let _ = self.amountRaised {
      return false
    }

    if let _ = self.goal {
      return false
    }

    return true
  }
}
