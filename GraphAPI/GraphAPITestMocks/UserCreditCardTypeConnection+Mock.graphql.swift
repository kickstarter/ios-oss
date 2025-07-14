// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class UserCreditCardTypeConnection: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.UserCreditCardTypeConnection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<UserCreditCardTypeConnection>>

  public struct MockFields {
    @Field<[CreditCard?]>("nodes") public var nodes
    @Field<Int>("totalCount") public var totalCount
  }
}

public extension Mock where O == UserCreditCardTypeConnection {
  convenience init(
    nodes: [Mock<CreditCard>?]? = nil,
    totalCount: Int? = nil
  ) {
    self.init()
    _setList(nodes, for: \.nodes)
    _setScalar(totalCount, for: \.totalCount)
  }
}
