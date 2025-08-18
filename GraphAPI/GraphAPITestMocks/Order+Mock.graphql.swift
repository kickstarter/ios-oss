// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Order: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Order
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Order>>

  public struct MockFields {
    @Field<GraphQLEnum<GraphAPI.CheckoutStateEnum>>("checkoutState") public var checkoutState
    @Field<GraphQLEnum<GraphAPI.CurrencyCode>>("currency") public var currency
    @Field<GraphAPI.ID>("id") public var id
    @Field<Int>("total") public var total
  }
}

public extension Mock where O == Order {
  convenience init(
    checkoutState: GraphQLEnum<GraphAPI.CheckoutStateEnum>? = nil,
    currency: GraphQLEnum<GraphAPI.CurrencyCode>? = nil,
    id: GraphAPI.ID? = nil,
    total: Int? = nil
  ) {
    self.init()
    _setScalar(checkoutState, for: \.checkoutState)
    _setScalar(currency, for: \.currency)
    _setScalar(id, for: \.id)
    _setScalar(total, for: \.total)
  }
}
