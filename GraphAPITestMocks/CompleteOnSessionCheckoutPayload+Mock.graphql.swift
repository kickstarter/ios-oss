// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CompleteOnSessionCheckoutPayload: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CompleteOnSessionCheckoutPayload
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CompleteOnSessionCheckoutPayload>>

  public struct MockFields {
    @Field<Checkout>("checkout") public var checkout
  }
}

public extension Mock where O == CompleteOnSessionCheckoutPayload {
  convenience init(
    checkout: Mock<Checkout>? = nil
  ) {
    self.init()
    _setEntity(checkout, for: \.checkout)
  }
}
