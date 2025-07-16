// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CreateCheckoutPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CreateCheckoutPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CreateCheckoutPayload>>

  public struct MockFields {
    @Field<Checkout>("checkout") public var checkout
    @Field<String>("clientMutationId") public var clientMutationId
  }
}

public extension Mock where O == CreateCheckoutPayload {
  convenience init(
    checkout: Mock<Checkout>? = nil,
    clientMutationId: String? = nil
  ) {
    self.init()
    _setEntity(checkout, for: \.checkout)
    _setScalar(clientMutationId, for: \.clientMutationId)
  }
}
