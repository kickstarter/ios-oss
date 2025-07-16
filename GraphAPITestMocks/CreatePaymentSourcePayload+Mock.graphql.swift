// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CreatePaymentSourcePayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CreatePaymentSourcePayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CreatePaymentSourcePayload>>

  public struct MockFields {
    @Field<String>("clientMutationId") public var clientMutationId
    @Field<Bool>("isSuccessful") public var isSuccessful
    @Field<CreditCard>("paymentSource") public var paymentSource
  }
}

public extension Mock where O == CreatePaymentSourcePayload {
  convenience init(
    clientMutationId: String? = nil,
    isSuccessful: Bool? = nil,
    paymentSource: Mock<CreditCard>? = nil
  ) {
    self.init()
    _setScalar(clientMutationId, for: \.clientMutationId)
    _setScalar(isSuccessful, for: \.isSuccessful)
    _setEntity(paymentSource, for: \.paymentSource)
  }
}
