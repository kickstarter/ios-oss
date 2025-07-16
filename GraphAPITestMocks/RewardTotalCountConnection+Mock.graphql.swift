// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RewardTotalCountConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RewardTotalCountConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RewardTotalCountConnection>>

  public struct MockFields {
    @Field<[Reward?]>("nodes") public var nodes
  }
}

public extension Mock where O == RewardTotalCountConnection {
  convenience init(
    nodes: [Mock<Reward>?]? = nil
  ) {
    self.init()
    _setList(nodes, for: \.nodes)
  }
}
