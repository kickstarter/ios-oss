extension ProjectStatsEnvelope {
  internal static let template = ProjectStatsEnvelope(
    // using `.template` causes a segfault in release builds
    cumulativeStats: ProjectStatsEnvelope.CumulativeStats(
      averagePledge: 0,
      backersCount: 0,
      goal: 0,
      percentRaised: 0,
      pledged: 0
    ),
    fundingDistribution: [.template],
    referralAggregateStats: ProjectStatsEnvelope.ReferralAggregateStats(
      custom: 0,
      external: 0,
      kickstarter: 0
    ),
    referralDistribution: [.template],
    rewardDistribution: [.template],
    videoStats: .template
  )
}
