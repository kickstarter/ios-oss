// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class ProjectBackerFriendsConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.ProjectBackerFriendsConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ProjectBackerFriendsConnection>>

  public struct MockFields {
    @Field<[User?]>("nodes") public var nodes
  }
}

public extension Mock where O == ProjectBackerFriendsConnection {
  convenience init(
    nodes: [Mock<User>?]? = nil
  ) {
    self.init()
    _setList(nodes, for: \.nodes)
  }
}
