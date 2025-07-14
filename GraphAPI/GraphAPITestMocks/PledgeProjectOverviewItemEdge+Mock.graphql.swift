// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PledgeProjectOverviewItemEdge: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PledgeProjectOverviewItemEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PledgeProjectOverviewItemEdge>>

  public struct MockFields {
    @Field<String>("cursor") public var cursor
    @Field<PledgeProjectOverviewItem>("node") public var node
  }
}

public extension Mock where O == PledgeProjectOverviewItemEdge {
  convenience init(
    cursor: String? = nil,
    node: Mock<PledgeProjectOverviewItem>? = nil
  ) {
    self.init()
    _setScalar(cursor, for: \.cursor)
    _setEntity(node, for: \.node)
  }
}
