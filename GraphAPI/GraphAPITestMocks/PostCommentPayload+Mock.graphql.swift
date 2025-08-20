// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PostCommentPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PostCommentPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PostCommentPayload>>

  public struct MockFields {
    @Field<Comment>("comment") public var comment
  }
}

public extension Mock where O == PostCommentPayload {
  convenience init(
    comment: Mock<Comment>? = nil
  ) {
    self.init()
    _setEntity(comment, for: \.comment)
  }
}
