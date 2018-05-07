import Prelude

extension ProjectStatsEnvelope {
  public enum lens {
    public static let cumulativeStats = Lens<ProjectStatsEnvelope, ProjectStatsEnvelope.CumulativeStats>(
      view: { $0.cumulativeStats },
      set: { ProjectStatsEnvelope(cumulativeStats: $0, fundingDistribution: $1.fundingDistribution,
        referralAggregateStats: $1.referralAggregateStats, referralDistribution: $1.referralDistribution,
        rewardDistribution: $1.rewardDistribution, videoStats: $1.videoStats) }
    )

    public static let fundingDistribution =
      Lens<ProjectStatsEnvelope, [ProjectStatsEnvelope.FundingDateStats]>(
        view: { $0.fundingDistribution },
        set: { ProjectStatsEnvelope(cumulativeStats: $1.cumulativeStats, fundingDistribution: $0,
          referralAggregateStats: $1.referralAggregateStats, referralDistribution: $1.referralDistribution,
          rewardDistribution: $1.rewardDistribution, videoStats: $1.videoStats) }
    )

    public static let referralAggregateStats =
      Lens<ProjectStatsEnvelope, ProjectStatsEnvelope.ReferralAggregateStats>(
      view: { $0.referralAggregateStats },
      set: { ProjectStatsEnvelope(cumulativeStats: $1.cumulativeStats,
        fundingDistribution: $1.fundingDistribution, referralAggregateStats: $0,
        referralDistribution: $1.referralDistribution, rewardDistribution: $1.rewardDistribution,
        videoStats: $1.videoStats) }
    )

    public static let referralDistribution =
      Lens<ProjectStatsEnvelope, [ProjectStatsEnvelope.ReferrerStats]>(
        view: { $0.referralDistribution },
        set: { ProjectStatsEnvelope(cumulativeStats: $1.cumulativeStats,
          fundingDistribution: $1.fundingDistribution, referralAggregateStats: $1.referralAggregateStats,
          referralDistribution: $0, rewardDistribution: $1.rewardDistribution, videoStats: $1.videoStats) }
    )

    public static let rewardDistribution = Lens<ProjectStatsEnvelope, [RewardStats]>(
      view: { $0.rewardDistribution },
      set: { ProjectStatsEnvelope(cumulativeStats: $1.cumulativeStats,
        fundingDistribution: $1.fundingDistribution, referralAggregateStats: $1.referralAggregateStats,
        referralDistribution: $1.referralDistribution, rewardDistribution: $0, videoStats: $1.videoStats) }
    )

    public static let videoStats = Lens<ProjectStatsEnvelope, ProjectStatsEnvelope.VideoStats?>(
      view: { $0.videoStats },
      set: { ProjectStatsEnvelope(cumulativeStats: $1.cumulativeStats,
        fundingDistribution: $1.fundingDistribution, referralAggregateStats: $1.referralAggregateStats,
        referralDistribution: $1.referralDistribution, rewardDistribution: $1.rewardDistribution,
        videoStats: $0) }
    )
  }
}
