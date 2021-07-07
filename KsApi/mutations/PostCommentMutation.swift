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
          author {
            id
            imageUrl(width: \(Constants.previewImageWidth))
            isCreator
            name
          }
          authorBadges
          body
          createdAt
          deleted
          parentId
          id
          replies {
            totalCount
          }
        }
      }
    }
    """
  }
}
