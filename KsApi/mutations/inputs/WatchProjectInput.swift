import Foundation

public struct WatchProjectInput: GraphMutationInput {
  let clientMutationId: String?
  let id: String
  let trackingContext: String?

  public init(clientMutationId: String? = nil, id: String, trackingContext: String? = nil) {
    self.clientMutationId = clientMutationId
    self.id = id
    self.trackingContext = trackingContext
  }

  public func toInputDictionary() -> [String: Any] {
    return [
      "clientMutationId": self.clientMutationId as Any,
      "id": self.id,
      "trackingContext": self.trackingContext as Any
    ]
  }
}
