import Prelude

extension Project.Dates {
  public enum lens {
    public static let deadline = Lens<Project.Dates, TimeInterval>(
      view: { $0.deadline },
      set: { Project.Dates(deadline: $0, featuredAt: $1.featuredAt, launchedAt: $1.launchedAt,
        potdAt: $1.potdAt, stateChangedAt: $1.stateChangedAt) }
    )

    public static let featuredAt = Lens<Project.Dates, TimeInterval?>(
      view: { $0.featuredAt },
      set: { Project.Dates(deadline: $1.deadline, featuredAt: $0, launchedAt: $1.launchedAt,
        potdAt: $1.potdAt, stateChangedAt: $1.stateChangedAt) }
    )

    public static let launchedAt = Lens<Project.Dates, TimeInterval>(
      view: { $0.launchedAt },
      set: { Project.Dates(deadline: $1.deadline, featuredAt: $1.featuredAt, launchedAt: $0,
        potdAt: $1.potdAt, stateChangedAt: $1.stateChangedAt) }
    )

    public static let potdAt = Lens<Project.Dates, TimeInterval?>(
      view: { $0.potdAt },
      set: { Project.Dates(deadline: $1.deadline, featuredAt: $1.featuredAt, launchedAt: $1.launchedAt,
        potdAt: $0, stateChangedAt: $1.stateChangedAt) }
    )

    public static let stateChangedAt = Lens<Project.Dates, TimeInterval>(
      view: { $0.stateChangedAt },
      set: { Project.Dates(deadline: $1.deadline, featuredAt: $1.featuredAt, launchedAt: $1.launchedAt,
        potdAt: $1.potdAt, stateChangedAt: $0) }
    )
  }
}
