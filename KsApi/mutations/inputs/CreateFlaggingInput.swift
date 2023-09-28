import Foundation

public struct CreateFlaggingInput: GraphMutationInput {
  let contentId: String
  let kind: GraphAPI.FlaggingKind
  let details: String?
  let clientMutationId: String

  public init(
    contentId: String,
    kind: GraphAPI.FlaggingKind,
    details: String?,
    clientMutationId: String
  ) {
    self.contentId = contentId
    self.kind = kind
    self.details = details
    self.clientMutationId = clientMutationId
  }

  public func toInputDictionary() -> [String: Any] {
    return [
      "contentId": self.contentId,
      "kind": self.kind,
      "details": self.details,
      "clientMutationId": self.clientMutationId
    ]
  }
}
