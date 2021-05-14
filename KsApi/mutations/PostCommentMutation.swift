import Foundation

public struct PostCommentMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation ($input: PostCommentInput!) {
      createComment(input: $input) {
        comment {
          body
          id
        }
      }
    }
    """
  }
}
