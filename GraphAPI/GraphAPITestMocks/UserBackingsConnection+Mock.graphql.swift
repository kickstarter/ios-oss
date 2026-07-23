// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class UserBackingsConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.UserBackingsConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UserBackingsConnection>>

  public struct MockFields {
    @Field<[Backing?]>("nodes") public var nodes
  }
}

public extension Mock where O == UserBackingsConnection {
  convenience init(
    nodes: [Mock<Backing>?]? = nil
  ) {
    self.init()
    _setList(nodes, for: \.nodes)
  }
}
