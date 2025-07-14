// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CommentConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CommentConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CommentConnection>>

  public struct MockFields {
    @Field<[CommentEdge?]>("edges") public var edges
    @Field<PageInfo>("pageInfo") public var pageInfo
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == CommentConnection {
  convenience init(
    edges: [Mock<CommentEdge>?]? = nil,
    pageInfo: Mock<PageInfo>? = nil,
    totalCount: Int? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
    _setEntity(pageInfo, for: \.pageInfo)
    _setScalar(totalCount, for: \.totalCount)
  }
}
