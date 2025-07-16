// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class ProjectFaqConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.ProjectFaqConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ProjectFaqConnection>>

  public struct MockFields {
    @Field<[ProjectFaq?]>("nodes") public var nodes
  }
}

public extension Mock where O == ProjectFaqConnection {
  convenience init(
    nodes: [Mock<ProjectFaq>?]? = nil
  ) {
    self.init()
    _setList(nodes, for: \.nodes)
  }
}
