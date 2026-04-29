// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class VideoFeedConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.VideoFeedConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<VideoFeedConnection>>

  public struct MockFields {
    @Field<[VideoFeedItem?]>("nodes") public var nodes
    @Field<PageInfo>("pageInfo") public var pageInfo
  }
}

public extension Mock where O == VideoFeedConnection {
  convenience init(
    nodes: [Mock<VideoFeedItem>?]? = nil,
    pageInfo: Mock<PageInfo>? = nil
  ) {
    self.init()
    _setList(nodes, for: \.nodes)
    _setEntity(pageInfo, for: \.pageInfo)
  }
}
