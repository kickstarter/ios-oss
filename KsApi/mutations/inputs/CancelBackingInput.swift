import Foundation

public struct CancelBackingInput: GraphMutationInput {
  let backingId: String
  let cancellationReason: String?

  /**
   An input object for the CancelBackingMutation
   - parameter backingId: The graphID of the backing
   - parameter cancellationReason: An optional cancellation reason string
   */
  public init(backingId: String, cancellationReason: String?) {
    self.backingId = backingId
    self.cancellationReason = cancellationReason
  }
}

extension CancelBackingInput: Encodable {
  enum CodingKeys: String, CodingKey {
    case backingId = "id"
    case cancellationReason = "note"
  }
}
