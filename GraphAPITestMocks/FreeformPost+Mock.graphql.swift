// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class FreeformPost: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.FreeformPost
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<FreeformPost>>

  public struct MockFields {
    @Field<CommentConnection>("comments") public var comments
    @Field<GraphAPI.ID>("id") public var id
  }
}

public extension Mock where O == FreeformPost {
  convenience init(
    comments: Mock<CommentConnection>? = nil,
    id: GraphAPI.ID? = nil
  ) {
    self.init()
    _setEntity(comments, for: \.comments)
    _setScalar(id, for: \.id)
  }
}
