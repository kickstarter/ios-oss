// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class PaymentPlan: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.PaymentPlan
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PaymentPlan>>

  public struct MockFields {
    @Field<Bool>("amountIsPledgeOverTimeEligible") public var amountIsPledgeOverTimeEligible
    @Field<[PaymentIncrement]>("paymentIncrements") public var paymentIncrements
  }
}

public extension Mock where O == PaymentPlan {
  convenience init(
    amountIsPledgeOverTimeEligible: Bool? = nil,
    paymentIncrements: [Mock<PaymentIncrement>]? = nil
  ) {
    self.init()
    _setScalar(amountIsPledgeOverTimeEligible, for: \.amountIsPledgeOverTimeEligible)
    _setList(paymentIncrements, for: \.paymentIncrements)
  }
}
