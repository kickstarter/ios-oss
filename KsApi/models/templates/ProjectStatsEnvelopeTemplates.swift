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
    referralDistribution: [.template],
    rewardDistribution: [.template],
    videoStats: .template
  )
}
