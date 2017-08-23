import Prelude

extension ProjectStatsEnvelope.ReferrerStats {
  public enum lens {
    public static let backersCount = Lens<ProjectStatsEnvelope.ReferrerStats, Int>(
      view: { $0.backersCount },
      set: { ProjectStatsEnvelope.ReferrerStats(backersCount: $0, code: $1.code,
        percentageOfDollars: $1.percentageOfDollars, pledged: $1.pledged, referrerName: $1.referrerName,
        referrerType: $1.referrerType) }
    )

    public static let code = Lens<ProjectStatsEnvelope.ReferrerStats, String>(
      view: { $0.code },
      set: { ProjectStatsEnvelope.ReferrerStats(backersCount: $1.backersCount, code: $0,
        percentageOfDollars: $1.percentageOfDollars, pledged: $1.pledged, referrerName: $1.referrerName,
        referrerType: $1.referrerType) }
    )

    public static let percentageOfDollars = Lens<ProjectStatsEnvelope.ReferrerStats, Double>(
      view: { $0.percentageOfDollars },
      set: { ProjectStatsEnvelope.ReferrerStats(backersCount: $1.backersCount, code: $1.code,
        percentageOfDollars: $0, pledged: $1.pledged, referrerName: $1.referrerName,
        referrerType: $1.referrerType) }
    )

    public static let pledged = Lens<ProjectStatsEnvelope.ReferrerStats, Double>(
      view: { $0.pledged },
      set: { ProjectStatsEnvelope.ReferrerStats(backersCount: $1.backersCount, code: $1.code,
        percentageOfDollars: $1.percentageOfDollars, pledged: $0, referrerName: $1.referrerName,
        referrerType: $1.referrerType) }
    )

    public static let referrerName = Lens<ProjectStatsEnvelope.ReferrerStats, String>(
      view: { $0.referrerName },
      set: { ProjectStatsEnvelope.ReferrerStats(backersCount: $1.backersCount, code: $1.code,
        percentageOfDollars: $1.percentageOfDollars, pledged: $1.pledged, referrerName: $0,
        referrerType: $1.referrerType) }
    )

    public static let referrerType =
      Lens<ProjectStatsEnvelope.ReferrerStats, ProjectStatsEnvelope.ReferrerStats.ReferrerType>(
        view: { $0.referrerType },
        set: { ProjectStatsEnvelope.ReferrerStats(backersCount: $1.backersCount, code: $1.code,
          percentageOfDollars: $1.percentageOfDollars, pledged: $1.pledged, referrerName: $1.referrerName,
          referrerType: $0) }
    )
  }
}
