import Foundation

public struct GraphMutationUnwatchProjectResponseEnvelope: Decodable {
  public private(set) var unwatchProject: UnwatchProject

  public struct UnwatchProject: Decodable {
    public private(set) var project: Project

    public struct Project: Decodable {
      public private(set) var id: String
      public private(set) var isWatched: Bool
    }
  }
}
