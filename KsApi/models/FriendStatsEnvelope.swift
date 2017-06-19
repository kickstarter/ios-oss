import Argo
import Curry
import Runes

public struct FriendStatsEnvelope {
  public let stats: Stats

  public struct Stats {
    public let friendProjectsCount: Int
    public let remoteFriendsCount: Int
  }
}

extension FriendStatsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<FriendStatsEnvelope> {
    return curry(FriendStatsEnvelope.init)
      <^> json <| "stats"
  }
}

extension FriendStatsEnvelope.Stats: Decodable {
  public static func decode(_ json: JSON) -> Decoded<FriendStatsEnvelope.Stats> {
    return curry(FriendStatsEnvelope.Stats.init)
      <^> json <| "friend_projects_count"
      <*> json <| "remote_friends_count"
  }
}
