import Foundation

public struct WatchProjectInput: GraphMutationInput {
  let id: String

  public init(id: String) {
    self.id = id
  }

  public func toInputDictionary() -> [String: Any] {
    return ["id": self.id]
  }
}
