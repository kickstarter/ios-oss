// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RewardItemEdge: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RewardItemEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RewardItemEdge>>

  public struct MockFields {
    @Field<RewardItem>("node") public var node
    @Field<Int>("quantity") public var quantity
  }
}

public extension Mock where O == RewardItemEdge {
  convenience init(
    node: Mock<RewardItem>? = nil,
    quantity: Int? = nil
  ) {
    self.init()
    _setEntity(node, for: \.node)
    _setScalar(quantity, for: \.quantity)
  }
}
