// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RewardShippingRulesConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RewardShippingRulesConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RewardShippingRulesConnection>>

  public struct MockFields {
    @Field<[ShippingRule?]>("nodes") public var nodes
  }
}

public extension Mock where O == RewardShippingRulesConnection {
  convenience init(
    nodes: [Mock<ShippingRule>?]? = nil
  ) {
    self.init()
    _setList(nodes, for: \.nodes)
  }
}
