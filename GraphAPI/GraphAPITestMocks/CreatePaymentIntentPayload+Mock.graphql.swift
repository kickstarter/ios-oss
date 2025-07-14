// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CreatePaymentIntentPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CreatePaymentIntentPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CreatePaymentIntentPayload>>

  public struct MockFields {
    @Field<String>("clientMutationId") public var clientMutationId
    @Field<String>("clientSecret") public var clientSecret
  }
}

public extension Mock where O == CreatePaymentIntentPayload {
  convenience init(
    clientMutationId: String? = nil,
    clientSecret: String? = nil
  ) {
    self.init()
    _setScalar(clientMutationId, for: \.clientMutationId)
    _setScalar(clientSecret, for: \.clientSecret)
  }
}
