import Foundation

public struct GraphMutationWatchProjectResponseEnvelope: Swift.Decodable {
  public var watchProject: WatchProject

  public struct WatchProject: Swift.Decodable {
    public var project: Project

    public struct Project: Swift.Decodable {
      public var id: String
      public var isWatched: Bool
    }
  }
}
