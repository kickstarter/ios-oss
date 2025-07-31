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
    @Field<PaymentIncrementAmount>("refundedAmount") public var refundedAmount
    @Field<GraphAPI.ISO8601DateTime>("scheduledCollection") public var scheduledCollection
    @Field<GraphQLEnum<GraphAPI.PaymentIncrementState>>("state") public var state
    @Field<GraphQLEnum<GraphAPI.PaymentIncrementStateReason>>("stateReason") public var stateReason
  }
}

public extension Mock where O == PaymentIncrement {
  convenience init(
    amount: Mock<PaymentIncrementAmount>? = nil,
    refundedAmount: Mock<PaymentIncrementAmount>? = nil,
    scheduledCollection: GraphAPI.ISO8601DateTime? = nil,
    state: GraphQLEnum<GraphAPI.PaymentIncrementState>? = nil,
    stateReason: GraphQLEnum<GraphAPI.PaymentIncrementStateReason>? = nil
  ) {
    self.init()
    _setEntity(amount, for: \.amount)
    _setEntity(refundedAmount, for: \.refundedAmount)
    _setScalar(scheduledCollection, for: \.scheduledCollection)
    _setScalar(state, for: \.state)
    _setScalar(stateReason, for: \.stateReason)
  }
}
