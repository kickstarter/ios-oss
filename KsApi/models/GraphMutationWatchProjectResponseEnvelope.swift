import Foundation

public struct GraphMutationWatchProjectResponseEnvelope: Decodable {
  public private(set) var watchProject: WatchProject

  public struct WatchProject: Decodable {
    public private(set) var project: Project

    public struct Project: Decodable {
      public private(set) var id: String
      public private(set) var isWatched: Bool
    }
  }
}

public struct CreatePaymentMethodEnvelope: Decodable {
  public private(set) var errorMessage: String?
  public private(set) var isSuccessful: Bool
}
