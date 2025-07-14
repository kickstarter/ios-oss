import Foundation
import GraphAPI

extension GraphAPI.BlockUserInput {
  static func from(_ input: BlockUserInput) -> GraphAPI.BlockUserInput {
    return GraphAPI.BlockUserInput(blockUserId: input.blockUserId)
  }
}
