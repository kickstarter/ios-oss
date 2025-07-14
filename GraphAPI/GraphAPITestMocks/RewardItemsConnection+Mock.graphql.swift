// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RewardItemsConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RewardItemsConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RewardItemsConnection>>

  public struct MockFields {
    @Field<[RewardItemEdge?]>("edges") public var edges
  }
}

public extension Mock where O == RewardItemsConnection {
  convenience init(
    edges: [Mock<RewardItemEdge>?]? = nil
  ) {
    self.init()
    _setList(edges, for: \.edges)
  }
}
