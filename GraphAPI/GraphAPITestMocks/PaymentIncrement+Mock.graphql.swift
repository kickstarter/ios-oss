// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PaymentIncrement: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PaymentIncrement
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PaymentIncrement>>

  public struct MockFields {
    @Field<PaymentIncrementAmount>("amount") public var amount
    @Field<PaymentIncrementBadge>("badge") public var badge
    @Field<String>("refundUpdatedAmountInProjectNativeCurrency") public var refundUpdatedAmountInProjectNativeCurrency
    @Field<PaymentIncrementAmount>("refundedAmount") public var refundedAmount
    @Field<GraphAPI.ISO8601DateTime>("scheduledCollection") public var scheduledCollection
    @Field<GraphQLEnum<GraphAPI.PaymentIncrementState>>("state") public var state
  }
}

public extension Mock where O == PaymentIncrement {
  convenience init(
    amount: Mock<PaymentIncrementAmount>? = nil,
    badge: Mock<PaymentIncrementBadge>? = nil,
    refundUpdatedAmountInProjectNativeCurrency: String? = nil,
    refundedAmount: Mock<PaymentIncrementAmount>? = nil,
    scheduledCollection: GraphAPI.ISO8601DateTime? = nil,
    state: GraphQLEnum<GraphAPI.PaymentIncrementState>? = nil
  ) {
    self.init()
    _setEntity(amount, for: \.amount)
    _setEntity(badge, for: \.badge)
    _setScalar(refundUpdatedAmountInProjectNativeCurrency, for: \.refundUpdatedAmountInProjectNativeCurrency)
    _setEntity(refundedAmount, for: \.refundedAmount)
    _setScalar(scheduledCollection, for: \.scheduledCollection)
    _setScalar(state, for: \.state)
  }
}
