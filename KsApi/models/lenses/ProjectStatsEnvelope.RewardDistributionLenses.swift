import Prelude

extension ProjectStatsEnvelope.RewardStats {
  public enum lens {
    public static let backersCount = Lens<ProjectStatsEnvelope.RewardStats, Int>(
      view: { $0.backersCount },
      set: { ProjectStatsEnvelope.RewardStats(backersCount: $0, rewardId: $1.rewardId,
        minimum: $1.minimum, pledged: $1.pledged) }
    )

    public static let id = Lens<ProjectStatsEnvelope.RewardStats, Int>(
      view: { $0.rewardId },
      set: { ProjectStatsEnvelope.RewardStats(backersCount: $1.backersCount, rewardId: $0,
        minimum: $1.minimum, pledged: $1.pledged) }
    )

    public static let minimum = Lens<ProjectStatsEnvelope.RewardStats, Double?>(
      view: { $0.minimum },
      set: { ProjectStatsEnvelope.RewardStats(backersCount: $1.backersCount,
        rewardId: $1.rewardId, minimum: $0, pledged: $1.pledged) }
    )

    public static let pledged = Lens<ProjectStatsEnvelope.RewardStats, Int>(
      view: { $0.pledged },
      set: { ProjectStatsEnvelope.RewardStats(backersCount: $1.backersCount,
        rewardId: $1.rewardId, minimum: $1.minimum, pledged: $0) }
    )
  }
}
