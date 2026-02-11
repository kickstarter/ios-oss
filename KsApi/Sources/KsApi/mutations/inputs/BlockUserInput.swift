import Foundation

public struct BlockUserInput: GraphMutationInput, Encodable {
  let blockUserId: String

  public init(blockUserId: String) {
    self.blockUserId = blockUserId
  }
}
