import Foundation

public struct ProjectStatsEnvelope {
  public let cumulativeStats: CumulativeStats
  public let fundingDistribution: [FundingDateStats]
  public let referralAggregateStats: ReferralAggregateStats
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

  public struct ReferralAggregateStats {
    public let custom: Double
    public let external: Double
    public let kickstarter: Double
  }

  public struct ReferrerStats {
    public let backersCount: Int
    public let code: String
    public let percentageOfDollars: Double
    public let pledged: Double
    public let referrerName: String
    public let referrerType: ReferrerType

    public enum ReferrerType: String {
      case custom
      case external
      case `internal`
      case unknown
    }
  }

  public struct RewardStats {
    public let backersCount: Int
    public let rewardId: Int
    public let minimum: Double?
    public let pledged: Int

    public static let zero = RewardStats(backersCount: 0, rewardId: 0, minimum: 0.00, pledged: 0)
  }

  public struct VideoStats {
    public let externalCompletions: Int
    public let externalStarts: Int
    public let internalCompletions: Int
    public let internalStarts: Int
  }
}

extension ProjectStatsEnvelope: Decodable {
  private enum CodingKeys: String, CodingKey {
    case cumulativeStats = "cumulative"
    case fundingDistribution = "funding_distribution"
    case referralAggregateStats = "referral_aggregates"
    case referralDistribution = "referral_distribution"
    case rewardDistribution = "reward_distribution"
    case videoStats = "video_stats"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.cumulativeStats = try values.decode(CumulativeStats.self, forKey: .cumulativeStats)
    self.fundingDistribution = try values.decode(
      [OptionalObject<FundingDateStats>].self,
      forKey: .fundingDistribution
    ).compactMap { $0.value }
    self.referralAggregateStats = try values
      .decode(ReferralAggregateStats.self, forKey: .referralAggregateStats)
    self.referralDistribution = try values.decode([ReferrerStats].self, forKey: .referralDistribution)
    self.rewardDistribution = try values.decode([RewardStats].self, forKey: .rewardDistribution)
    self.videoStats = try values.decodeIfPresent(VideoStats.self, forKey: .videoStats)
  }
}

extension ProjectStatsEnvelope.CumulativeStats: Decodable {
  enum CodingKeys: String, CodingKey {
    case averagePledge = "average_pledge"
    case backersCount = "backers_count"
    case goal
    case percentRaised = "percent_raised"
    case pledged
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.averagePledge = try Int(values.decode(Double.self, forKey: .averagePledge))
    self.backersCount = try values.decode(Int.self, forKey: .backersCount)
    self.goal = try stringToIntOrZero(values.decode(String.self, forKey: .goal))
    self.percentRaised = try values.decode(Double.self, forKey: .percentRaised)
    self.pledged = try stringToIntOrZero(values.decode(String.self, forKey: .pledged))
  }
}

extension ProjectStatsEnvelope.CumulativeStats: Equatable {}
public func == (lhs: ProjectStatsEnvelope.CumulativeStats, rhs: ProjectStatsEnvelope.CumulativeStats)
  -> Bool {
  return lhs.averagePledge == rhs.averagePledge
}

extension ProjectStatsEnvelope.FundingDateStats: Decodable {
  private enum CodingKeys: String, CodingKey {
    case backersCount = "backers_count"
    case cumulativePledged = "cumulative_pledged"
    case cumulativeBackersCount = "cumulative_backers_count"
    case date
    case pledged
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.backersCount = try values.decodeIfPresent(Int.self, forKey: .backersCount) ?? 0
    if let value = try? values.decode(String.self, forKey: .cumulativePledged) {
      self.cumulativePledged = stringToIntOrZero(value)
    } else {
      self.cumulativePledged = try values.decode(Int.self, forKey: .cumulativePledged)
    }
    self.cumulativeBackersCount = try values.decode(Int.self, forKey: .cumulativeBackersCount)
    self.date = try values.decode(TimeInterval.self, forKey: .date)
    if let value = try? values.decode(String.self, forKey: .pledged) {
      self.pledged = stringToIntOrZero(value)
    } else {
      self.pledged = 0
    }
  }
}

extension ProjectStatsEnvelope.FundingDateStats: Equatable {}
public func == (lhs: ProjectStatsEnvelope.FundingDateStats, rhs: ProjectStatsEnvelope.FundingDateStats)
  -> Bool {
  return lhs.date == rhs.date
}

extension ProjectStatsEnvelope.ReferralAggregateStats: Decodable {
  private enum CodingKeys: String, CodingKey {
    case custom
    case external
    case kickstarter = "internal"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.custom = try values.decode(Double.self, forKey: .custom)
    self.external = try stringToDouble(values.decode(String.self, forKey: .external))
    self.kickstarter = try values.decode(Double.self, forKey: .kickstarter)
  }
}

extension ProjectStatsEnvelope.ReferralAggregateStats: Equatable {}
public func == (
  lhs: ProjectStatsEnvelope.ReferralAggregateStats,
  rhs: ProjectStatsEnvelope.ReferralAggregateStats
) -> Bool {
  return lhs.custom == rhs.custom &&
    lhs.external == rhs.external &&
    lhs.kickstarter == rhs.kickstarter
}

extension ProjectStatsEnvelope.ReferrerStats: Decodable {
  private enum CodingKeys: String, CodingKey {
    case backersCount = "backers_count"
    case code
    case percentageOfDollars = "percentage_of_dollars"
    case pledged
    case referrerName = "referrer_name"
    case referrerType = "referrer_type"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.backersCount = try values.decode(Int.self, forKey: .backersCount)
    self.code = try values.decode(String.self, forKey: .code)
    self.percentageOfDollars = try stringToDouble(values.decode(String.self, forKey: .percentageOfDollars))
    self.pledged = try stringToDouble(values.decode(String.self, forKey: .pledged))
    self.referrerName = try values.decode(String.self, forKey: .referrerName)
    self.referrerType = try values.decode(ReferrerType.self, forKey: .referrerType)
  }
}

extension ProjectStatsEnvelope.ReferrerStats: Equatable {}
public func == (lhs: ProjectStatsEnvelope.ReferrerStats, rhs: ProjectStatsEnvelope.ReferrerStats) -> Bool {
  return lhs.code == rhs.code
}

extension ProjectStatsEnvelope.ReferrerStats.ReferrerType: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      let value = try decoder.singleValueContainer().decode(String.self).lowercased()
      switch value {
      case "custom":
        self = .custom
      case "external":
        self = .external
      case "kickstarter":
        self = .internal
      default:
        self = .unknown
      }
    } catch {
      self = .unknown
    }
  }
}

extension ProjectStatsEnvelope.RewardStats: Decodable {
  private enum CodingKeys: String, CodingKey {
    case backersCount = "backers_count"
    case rewardId = "reward_id"
    case minimum
    case pledged
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.backersCount = try values.decode(Int.self, forKey: .backersCount)
    self.rewardId = try values.decode(Int.self, forKey: .rewardId)

    do {
      self.minimum = try values.decodeIfPresent(String.self, forKey: .minimum).flatMap(stringToDouble)
    } catch {
      self.minimum = try values.decodeIfPresent(Double.self, forKey: .minimum)
    }
    self.pledged = try stringToIntOrZero(values.decode(String.self, forKey: .pledged))
  }
}

extension ProjectStatsEnvelope.RewardStats: Equatable {}
public func == (lhs: ProjectStatsEnvelope.RewardStats, rhs: ProjectStatsEnvelope.RewardStats)
  -> Bool {
  return lhs.rewardId == rhs.rewardId
}

extension ProjectStatsEnvelope.VideoStats: Decodable {
  private enum CodingKeys: String, CodingKey {
    case externalCompletions = "external_completions"
    case externalStarts = "external_starts"
    case internalCompletions = "internal_completions"
    case internalStarts = "internal_starts"
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

private func stringToIntOrZero(_ string: String) -> Int {
  return
    Double(string).flatMap(Int.init)
      ?? Int(string)
      ?? 0
}

private func stringToDouble(_ string: String) -> Double {
  return Double(string) ?? 0
}

private struct OptionalObject<Base: Decodable>: Decodable {
  public let value: Base?

  public init(from decoder: Decoder) throws {
    do {
      let container = try decoder.singleValueContainer()
      self.value = try container.decode(Base.self)
    } catch {
      self.value = nil
    }
  }
}
