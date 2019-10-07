import Foundation

public struct CancelBackingInput: GraphMutationInput {
  let backingId: String
  let cancellationReason: String?
}

extension CancelBackingInput: Encodable {
  enum CodingKeys: String, CodingKey {
    case backingId = "id"
    case cancellationReason = "note"
  }
}
