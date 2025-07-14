// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CommentEdge: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CommentEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CommentEdge>>

  public struct MockFields {
    @Field<Comment>("node") public var node
  }
}

public extension Mock where O == CommentEdge {
  convenience init(
    node: Mock<Comment>? = nil
  ) {
    self.init()
    _setEntity(node, for: \.node)
  }
}
