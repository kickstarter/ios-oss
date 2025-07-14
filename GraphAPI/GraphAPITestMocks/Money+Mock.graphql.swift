// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Money: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Money
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Money>>

  public struct MockFields {
    @Field<String>("amount") public var amount
    @Field<GraphQLEnum<GraphAPI.CurrencyCode>>("currency") public var currency
    @Field<String>("symbol") public var symbol
  }
}

public extension Mock where O == Money {
  convenience init(
    amount: String? = nil,
    currency: GraphQLEnum<GraphAPI.CurrencyCode>? = nil,
    symbol: String? = nil
  ) {
    self.init()
    _setScalar(amount, for: \.amount)
    _setScalar(currency, for: \.currency)
    _setScalar(symbol, for: \.symbol)
  }
}
