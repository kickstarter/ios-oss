// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Checkout: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Checkout
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Checkout>>

  public struct MockFields {
    @Field<Backing>("backing") public var backing
    @Field<GraphAPI.ID>("id") public var id
    @Field<Validation>("isValidForOnSessionCheckout") public var isValidForOnSessionCheckout
    @Field<String>("paymentUrl") public var paymentUrl
    @Field<GraphQLEnum<GraphAPI.CheckoutState>>("state") public var state
  }
}

public extension Mock where O == Checkout {
  convenience init(
    backing: Mock<Backing>? = nil,
    id: GraphAPI.ID? = nil,
    isValidForOnSessionCheckout: Mock<Validation>? = nil,
    paymentUrl: String? = nil,
    state: GraphQLEnum<GraphAPI.CheckoutState>? = nil
  ) {
    self.init()
    _setEntity(backing, for: \.backing)
    _setScalar(id, for: \.id)
    _setEntity(isValidForOnSessionCheckout, for: \.isValidForOnSessionCheckout)
    _setScalar(paymentUrl, for: \.paymentUrl)
    _setScalar(state, for: \.state)
  }
}
