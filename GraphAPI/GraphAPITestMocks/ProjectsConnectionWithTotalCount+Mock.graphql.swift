// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class ProjectsConnectionWithTotalCount: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.ProjectsConnectionWithTotalCount
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ProjectsConnectionWithTotalCount>>

  public struct MockFields {
    @Field<[Project?]>("nodes") public var nodes
    @Field<PageInfo>("pageInfo") public var pageInfo
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == ProjectsConnectionWithTotalCount {
  convenience init(
    nodes: [Mock<Project>?]? = nil,
    pageInfo: Mock<PageInfo>? = nil,
    totalCount: Int? = nil
  ) {
    self.init()
    _setList(nodes, for: \.nodes)
    _setEntity(pageInfo, for: \.pageInfo)
    _setScalar(totalCount, for: \.totalCount)
  }
}
