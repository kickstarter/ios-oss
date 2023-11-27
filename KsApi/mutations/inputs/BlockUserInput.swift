import Foundation

public struct BlockUserInput: GraphMutationInput, Encodable {
  let blockUserId: String
}
