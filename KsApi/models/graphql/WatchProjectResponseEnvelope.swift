import Foundation

public struct WatchProjectResponseEnvelope: Decodable {
  public var watchProject: WatchProject

  public struct WatchProject: Decodable {
    public var project: Project

    public struct Project: Decodable {
      public var id: String
      public var isWatched: Bool
    }
  }
}
