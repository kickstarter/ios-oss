import Prelude

extension User.Stats {
  public enum lens {
    public static let backedProjectsCount = Lens<User.Stats, Int?>(
      view: { $0.backedProjectsCount },
      set: { User.Stats(backedProjectsCount: $0, createdProjectsCount: $1.createdProjectsCount,
        memberProjectsCount: $1.memberProjectsCount, starredProjectsCount: $1.starredProjectsCount,
        unansweredSurveysCount: $1.unansweredSurveysCount, unreadMessagesCount: $1.unreadMessagesCount) }
    )

    public static let createdProjectsCount = Lens<User.Stats, Int?>(
      view: { $0.createdProjectsCount },
      set: { User.Stats(backedProjectsCount: $1.backedProjectsCount, createdProjectsCount: $0,
        memberProjectsCount: $1.memberProjectsCount, starredProjectsCount: $1.starredProjectsCount,
        unansweredSurveysCount: $1.unansweredSurveysCount, unreadMessagesCount: $1.unreadMessagesCount) }
    )

    public static let memberProjectsCount = Lens<User.Stats, Int?>(
      view: { $0.memberProjectsCount },
      set: { User.Stats(backedProjectsCount: $1.backedProjectsCount,
        createdProjectsCount: $1.createdProjectsCount, memberProjectsCount: $0,
        starredProjectsCount: $1.starredProjectsCount, unansweredSurveysCount: $1.unansweredSurveysCount,
        unreadMessagesCount: $1.unreadMessagesCount) }
    )

    public static let starredProjectsCount = Lens<User.Stats, Int?>(
      view: { $0.starredProjectsCount },
      set: { User.Stats(backedProjectsCount: $1.backedProjectsCount,
        createdProjectsCount: $1.createdProjectsCount, memberProjectsCount: $1.memberProjectsCount,
        starredProjectsCount: $0, unansweredSurveysCount: $1.unansweredSurveysCount,
        unreadMessagesCount: $1.unreadMessagesCount) }
    )
  }
}
