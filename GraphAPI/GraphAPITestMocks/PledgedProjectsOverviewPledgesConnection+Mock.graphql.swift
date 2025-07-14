// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PledgedProjectsOverviewPledgesConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PledgedProjectsOverviewPledgesConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PledgedProjectsOverviewPledgesConnection>>

  public struct MockFields {
    @Field<[PledgeProjectOverviewItemEdge?]>("edges") public var edges
    @Field<PageInfo>("pageInfo") public var pageInfo
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == PledgedProjectsOverviewPledgesConnection {
  convenience init(
    edges: [Mock<PledgeProjectOverviewItemEdge>?]? = nil,
    pageInfo: Mock<PageInfo>? = nil,
    totalCount: Int? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
    _setEntity(pageInfo, for: \.pageInfo)
    _setScalar(totalCount, for: \.totalCount)
  }
}
