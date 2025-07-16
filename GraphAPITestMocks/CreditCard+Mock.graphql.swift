// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class CreditCard: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.CreditCard
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CreditCard>>

  public struct MockFields {
    @Field<GraphAPI.Date>("expirationDate") public var expirationDate
    @Field<String>("id") public var id
    @Field<String>("lastFour") public var lastFour
    @Field<GraphQLEnum<GraphAPI.CreditCardPaymentType>>("paymentType") public var paymentType
    @Field<String>("stripeCardId") public var stripeCardId
    @Field<GraphQLEnum<GraphAPI.CreditCardTypes>>("type") public var type
  }
}

public extension Mock where O == CreditCard {
  convenience init(
    expirationDate: GraphAPI.Date? = nil,
    id: String? = nil,
    lastFour: String? = nil,
    paymentType: GraphQLEnum<GraphAPI.CreditCardPaymentType>? = nil,
    stripeCardId: String? = nil,
    type: GraphQLEnum<GraphAPI.CreditCardTypes>? = nil
  ) {
    self.init()
    _setScalar(expirationDate, for: \.expirationDate)
    _setScalar(id, for: \.id)
    _setScalar(lastFour, for: \.lastFour)
    _setScalar(paymentType, for: \.paymentType)
    _setScalar(stripeCardId, for: \.stripeCardId)
    _setScalar(type, for: \.type)
  }
}
