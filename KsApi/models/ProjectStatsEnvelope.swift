import Argo
import Curry
import Runes

public struct ProjectStatsEnvelope {
  public let cumulativeStats: CumulativeStats
  public let fundingDistribution: [FundingDateStats]
  public let referralDistribution: [ReferrerStats]
  public let rewardDistribution: [RewardStats]
  public let videoStats: VideoStats?

  public struct CumulativeStats {
    public let averagePledge: Int
    public let backersCount: Int
    public let goal: Int
    public let percentRaised: Double
    public let pledged: Int
  }

  public struct FundingDateStats {
    public let backersCount: Int
    public let cumulativePledged: Int
    public let cumulativeBackersCount: Int
    public let date: TimeInterval
    public let pledged: Int
  }

  public struct ReferrerStats {
    public let backersCount: Int
    public let code: String
    public let percentageOfDollars: Double
    public let pledged: Int
    public let referrerName: String
    public let referrerType: ReferrerType

    public enum ReferrerType {
      case custom
      case external
      case `internal`
      case unknown
    }
  }

  public struct RewardStats {
    public let backersCount: Int
    public let rewardId: Int
    public let minimum: Int?
    public let pledged: Int

    public static let zero = RewardStats(backersCount: 0, rewardId: 0, minimum: 0, pledged: 0)
  }

  public struct VideoStats {
    public let externalCompletions: Int
    public let externalStarts: Int
    public let internalCompletions: Int
    public let internalStarts: Int
  }
}

extension ProjectStatsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectStatsEnvelope> {
    return curry(ProjectStatsEnvelope.init)
      <^> json <| "cumulative"
      <*> decodedJSON(json, forKey: "funding_distribution").flatMap(decodeSuccessfulFundingStats)
      <*> json <|| "referral_distribution"
      <*> json <|| "reward_distribution"
      <*> json <|? "video_stats"
  }
}

extension ProjectStatsEnvelope.CumulativeStats: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectStatsEnvelope.CumulativeStats> {
    let create = curry(ProjectStatsEnvelope.CumulativeStats.init)
    return create
      <^> json <| "average_pledge"
      <*> json <| "backers_count"
      <*> (json <| "goal" >>- stringToIntOrZero)
      <*> json <| "percent_raised"
      <*> (json <| "pledged" >>- stringToIntOrZero)
  }
}

extension ProjectStatsEnvelope.CumulativeStats: Equatable {}
public func == (lhs: ProjectStatsEnvelope.CumulativeStats, rhs: ProjectStatsEnvelope.CumulativeStats)
  -> Bool {
    return lhs.averagePledge == rhs.averagePledge
}

extension ProjectStatsEnvelope.FundingDateStats: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectStatsEnvelope.FundingDateStats> {
    let create = curry(ProjectStatsEnvelope.FundingDateStats.init)
    return create
      <^> (json <| "backers_count" <|> .success(0))
      <*> ((json <| "cumulative_pledged" >>- stringToIntOrZero) <|> (json <| "cumulative_pledged"))
      <*> json <| "cumulative_backers_count"
      <*> json <| "date"
      <*> ((json <| "pledged" >>- stringToIntOrZero) <|> .success(0))
  }
}

extension ProjectStatsEnvelope.FundingDateStats: Equatable {}
public func == (lhs: ProjectStatsEnvelope.FundingDateStats, rhs: ProjectStatsEnvelope.FundingDateStats)
  -> Bool {
    return lhs.date == rhs.date
}

extension ProjectStatsEnvelope.ReferrerStats: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectStatsEnvelope.ReferrerStats> {
    let create = curry(ProjectStatsEnvelope.ReferrerStats.init)
    let tmp = create
      <^> json <| "backers_count"
      <*> json <| "code"
      <*> (json <| "percentage_of_dollars" >>- stringToDouble)
    return tmp
      <*> (json <| "pledged" >>- stringToIntOrZero)
      <*> json <| "referrer_name"
      <*> json <| "referrer_type"
  }
}

extension ProjectStatsEnvelope.ReferrerStats: Equatable {}
public func == (lhs: ProjectStatsEnvelope.ReferrerStats, rhs: ProjectStatsEnvelope.ReferrerStats) -> Bool {
  return lhs.code == rhs.code
}

extension ProjectStatsEnvelope.ReferrerStats.ReferrerType: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectStatsEnvelope.ReferrerStats.ReferrerType> {
    if case .string(let referrerType) = json {
      switch referrerType.lowercased() {
      case "custom":
        return .success(.custom)
      case "external":
        return .success(.external)
      case "kickstarter":
        return .success(.`internal`)
      default:
        return .success(.unknown)
      }
    }
    return .success(.unknown)
  }
}

extension ProjectStatsEnvelope.RewardStats: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectStatsEnvelope.RewardStats> {
    return curry(ProjectStatsEnvelope.RewardStats.init)
      <^> json <| "backers_count"
      <*> json <| "reward_id"
      <*> ((json <|? "minimum" >>- stringToInt) <|> (json <|? "minimum"))
      <*> (json <| "pledged" >>- stringToIntOrZero)
  }
}

extension ProjectStatsEnvelope.RewardStats: Equatable {}
public func == (lhs: ProjectStatsEnvelope.RewardStats, rhs: ProjectStatsEnvelope.RewardStats)
  -> Bool {
  return lhs.rewardId == rhs.rewardId
}

extension ProjectStatsEnvelope.VideoStats: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectStatsEnvelope.VideoStats> {
    let create = curry(ProjectStatsEnvelope.VideoStats.init)
    return create
      <^> json <| "external_completions"
      <*> json <| "external_starts"
      <*> json <| "internal_completions"
      <*> json <| "internal_starts"
  }
}

extension ProjectStatsEnvelope.VideoStats: Equatable {}
public func == (lhs: ProjectStatsEnvelope.VideoStats, rhs: ProjectStatsEnvelope.VideoStats) -> Bool {
  return
    lhs.externalCompletions == rhs.externalCompletions &&
    lhs.externalStarts == rhs.externalStarts &&
    lhs.internalCompletions == rhs.internalCompletions &&
    lhs.internalStarts == rhs.internalStarts
}

private func decodeSuccessfulFundingStats(_ json: JSON) -> Decoded<[ProjectStatsEnvelope.FundingDateStats]> {
  switch json {
  case let .array(arrayJSON):
    let decodeds = arrayJSON
      .map(ProjectStatsEnvelope.FundingDateStats.decode)
    let successes = catDecoded(decodeds).map(Decoded.success)
    return sequence(successes)
  default:
    return .failure(.custom("Failed decoded values emitted."))
  }
}

private func stringToIntOrZero(_ string: String) -> Decoded<Int> {
  return
    Double(string).flatMap(Int.init).map(Decoded.success)
      ?? Int(string).map(Decoded.success)
      ?? .success(0)
}

private func stringToInt(_ string: String?) -> Decoded<Int?> {
  guard let string = string else { return .success(nil) }

  return
    Double(string).flatMap(Int.init).map(Decoded.success)
      ?? Int(string).map(Decoded.success)
      ?? .failure(.custom("Could not parse string into int."))
}

private func stringToDouble(_ string: String) -> Decoded<Double> {
  return Double(string).map(Decoded.success) ?? .success(0)
}
