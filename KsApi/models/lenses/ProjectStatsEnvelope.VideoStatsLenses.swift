import Prelude

extension ProjectStatsEnvelope.VideoStats {
  public enum lens {
    public static let externalCompletions = Lens<ProjectStatsEnvelope.VideoStats, Int>(
      view: { $0.externalCompletions },
      set: { ProjectStatsEnvelope.VideoStats(externalCompletions: $0, externalStarts: $1.externalStarts,
        internalCompletions: $1.internalCompletions, internalStarts: $1.internalStarts) }
    )

    public static let externalStarts = Lens<ProjectStatsEnvelope.VideoStats, Int>(
      view: { $0.externalStarts },
      set: { ProjectStatsEnvelope.VideoStats(externalCompletions: $1.externalCompletions, externalStarts: $0,
        internalCompletions: $1.internalCompletions, internalStarts: $1.internalStarts) }
    )

    public static let internalCompletions = Lens<ProjectStatsEnvelope.VideoStats, Int>(
      view: { $0.internalCompletions },
      set: { ProjectStatsEnvelope.VideoStats(externalCompletions: $1.externalCompletions,
        externalStarts: $1.externalStarts, internalCompletions: $0, internalStarts: $1.internalStarts) }
    )

    public static let internalStarts = Lens<ProjectStatsEnvelope.VideoStats, Int>(
      view: { $0.internalStarts },
      set: { ProjectStatsEnvelope.VideoStats(externalCompletions: $1.externalCompletions,
        externalStarts: $1.externalStarts, internalCompletions: $1.internalCompletions, internalStarts: $0) }
    )
  }
}
