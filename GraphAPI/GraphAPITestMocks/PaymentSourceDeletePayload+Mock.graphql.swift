// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PaymentSourceDeletePayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PaymentSourceDeletePayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PaymentSourceDeletePayload>>

  public struct MockFields {
    @Field<User>("user") public var user
  }
}

public extension Mock where O == PaymentSourceDeletePayload {
  convenience init(
    user: Mock<User>? = nil
  ) {
    self.init()
    _setEntity(user, for: \.user)
  }
}
