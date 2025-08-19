// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PaymentIncrementAmount: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PaymentIncrementAmount
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PaymentIncrementAmount>>

  public struct MockFields {
    @Field<String>("amountFormattedInProjectNativeCurrency") public var amountFormattedInProjectNativeCurrency
    @Field<String>("currency") public var currency
  }
}

public extension Mock where O == PaymentIncrementAmount {
  convenience init(
    amountFormattedInProjectNativeCurrency: String? = nil,
    currency: String? = nil
  ) {
    self.init()
    _setScalar(amountFormattedInProjectNativeCurrency, for: \.amountFormattedInProjectNativeCurrency)
    _setScalar(currency, for: \.currency)
  }
}
