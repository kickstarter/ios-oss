import Prelude

extension FriendStatsEnvelope {
  public enum lens {
    public static let stats = Lens<FriendStatsEnvelope, FriendStatsEnvelope.Stats>(
      view: { $0.stats },
      set: { stats, _ in FriendStatsEnvelope(stats: stats) }
    )
  }
}

extension Lens where Whole == FriendStatsEnvelope, Part == FriendStatsEnvelope.Stats {
  public var friendProjectsCount: Lens<FriendStatsEnvelope, Int> {
    return FriendStatsEnvelope.lens.stats..FriendStatsEnvelope.Stats.lens.friendProjectsCount
  }

  public var remoteFriendsCount: Lens<FriendStatsEnvelope, Int> {
    return FriendStatsEnvelope.lens.stats..FriendStatsEnvelope.Stats.lens.remoteFriendsCount
  }
}
