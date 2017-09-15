import Argo
import Curry
import Runes

public struct FriendStatsEnvelope {
  public private(set) var stats: Stats

  public struct Stats {
    public private(set) var friendProjectsCount: Int
    public private(set) var remoteFriendsCount: Int
  }
}

extension FriendStatsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<FriendStatsEnvelope> {
    return curry(FriendStatsEnvelope.init)
      <^> json <| "stats"
  }
}

extension FriendStatsEnvelope.Stats: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<FriendStatsEnvelope.Stats> {
    return curry(FriendStatsEnvelope.Stats.init)
      <^> json <| "friend_projects_count"
      <*> json <| "remote_friends_count"
  }
}
