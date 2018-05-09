import Prelude

extension ProjectStatsEnvelope.ReferralAggregateStats {
  public enum lens {
    public static let custom = Lens<ProjectStatsEnvelope.ReferralAggregateStats, Double>(
    view: { $0.custom },
    set: { ProjectStatsEnvelope.ReferralAggregateStats(custom: $0, external: $1.external,
      kickstarter: $1.kickstarter ) }
    )

    public static let external = Lens<ProjectStatsEnvelope.ReferralAggregateStats, Double>(
      view: { $0.external },
      set: { ProjectStatsEnvelope.ReferralAggregateStats(custom: $1.custom, external: $0,
        kickstarter: $1.kickstarter ) }
    )

    public static let kickstarter = Lens<ProjectStatsEnvelope.ReferralAggregateStats, Double>(
    view: { $0.kickstarter },
    set: { ProjectStatsEnvelope.ReferralAggregateStats(custom: $1.custom, external: $1.external,
      kickstarter: $0) }
    )
  }
}
