import Foundation

public struct GraphMutationUnwatchProjectResponseEnvelope: Decodable {
  public let unwatchProject: UnwatchProject

  public struct UnwatchProject: Decodable {
    public let project: Project

    public struct Project: Decodable {
      public let id: String
      public let isWatched: Bool
    }
  }
}
