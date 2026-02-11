import Prelude

extension FriendStatsEnvelope.Stats {
  public enum lens {
    public static let friendProjectsCount = Lens<FriendStatsEnvelope.Stats, Int>(
      view: { $0.friendProjectsCount },
      set: { FriendStatsEnvelope.Stats(friendProjectsCount: $0, remoteFriendsCount: $1.remoteFriendsCount) }
    )

    public static let remoteFriendsCount = Lens<FriendStatsEnvelope.Stats, Int>(
      view: { $0.remoteFriendsCount },
      set: { FriendStatsEnvelope.Stats(friendProjectsCount: $1.friendProjectsCount, remoteFriendsCount: $0) }
    )
  }
}
