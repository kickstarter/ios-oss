// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RewardItem: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RewardItem
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RewardItem>>

  public struct MockFields {
    @Field<GraphAPI.ID>("id") public var id
    @Field<String>("name") public var name
  }
}

public extension Mock where O == RewardItem {
  convenience init(
    id: GraphAPI.ID? = nil,
    name: String? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(name, for: \.name)
  }
}
