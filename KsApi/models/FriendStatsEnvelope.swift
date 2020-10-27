import Curry
import Runes

public struct FriendStatsEnvelope {
  public let stats: Stats

  public struct Stats {
    public let friendProjectsCount: Int
    public let remoteFriendsCount: Int
  }
}

extension FriendStatsEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case stats = "stats"
  }
}

extension FriendStatsEnvelope.Stats: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case friendProjectsCount = "friend_projects_count"
    case remoteFriendsCount = "remote_friends_count"
  }
}

/*
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
*/
