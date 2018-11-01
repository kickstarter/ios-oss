import Foundation

public struct GraphMutationWatchProjectResponseEnvelope: Decodable {
  public let watchProject: WatchProject

  public struct WatchProject: Decodable {
    public let project: Project

    public struct Project: Decodable {
      public let id: String
    }
  }
}
