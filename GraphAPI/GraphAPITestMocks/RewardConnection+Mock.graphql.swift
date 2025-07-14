// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class RewardConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.RewardConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<RewardConnection>>

  public struct MockFields {
    @Field<PageInfo>("pageInfo") public var pageInfo
  }
}

public extension Mock where O == RewardConnection {
  convenience init(
    pageInfo: Mock<PageInfo>? = nil
  ) {
    self.init()
    _setEntity(pageInfo, for: \.pageInfo)
  }
}
