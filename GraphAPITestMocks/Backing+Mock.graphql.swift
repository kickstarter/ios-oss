// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Backing: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Backing
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Backing>>

  public struct MockFields {
    @Field<RewardTotalCountConnection>("addOns") public var addOns
    @Field<Money>("amount") public var amount
    @Field<User>("backer") public var backer
    @Field<Bool>("backerCompleted") public var backerCompleted
    @Field<String>("backingDetailsPageRoute") public var backingDetailsPageRoute
    @Field<Money>("bonusAmount") public var bonusAmount
    @Field<Bool>("cancelable") public var cancelable
    @Field<String>("clientSecret") public var clientSecret
    @Field<Address>("deliveryAddress") public var deliveryAddress
    @Field<String>("errorReason") public var errorReason
    @Field<GraphAPI.ID>("id") public var id
    @Field<Bool>("isLatePledge") public var isLatePledge
    @Field<Location>("location") public var location
    @Field<Order>("order") public var order
    @Field<[PaymentIncrement]>("paymentIncrements") public var paymentIncrements
    @Field<PaymentSource>("paymentSource") public var paymentSource
    @Field<GraphAPI.DateTime>("pledgedOn") public var pledgedOn
    @Field<Project>("project") public var project
    @Field<Bool>("requiresAction") public var requiresAction
    @Field<Reward>("reward") public var reward
    @Field<Money>("rewardsAmount") public var rewardsAmount
    @Field<Int>("sequence") public var sequence
    @Field<Money>("shippingAmount") public var shippingAmount
    @Field<GraphQLEnum<GraphAPI.BackingState>>("status") public var status
  }
}

public extension Mock where O == Backing {
  convenience init(
    addOns: Mock<RewardTotalCountConnection>? = nil,
    amount: Mock<Money>? = nil,
    backer: Mock<User>? = nil,
    backerCompleted: Bool? = nil,
    backingDetailsPageRoute: String? = nil,
    bonusAmount: Mock<Money>? = nil,
    cancelable: Bool? = nil,
    clientSecret: String? = nil,
    deliveryAddress: Mock<Address>? = nil,
    errorReason: String? = nil,
    id: GraphAPI.ID? = nil,
    isLatePledge: Bool? = nil,
    location: Mock<Location>? = nil,
    order: Mock<Order>? = nil,
    paymentIncrements: [Mock<PaymentIncrement>]? = nil,
    paymentSource: AnyMock? = nil,
    pledgedOn: GraphAPI.DateTime? = nil,
    project: Mock<Project>? = nil,
    requiresAction: Bool? = nil,
    reward: Mock<Reward>? = nil,
    rewardsAmount: Mock<Money>? = nil,
    sequence: Int? = nil,
    shippingAmount: Mock<Money>? = nil,
    status: GraphQLEnum<GraphAPI.BackingState>? = nil
  ) {
    self.init()
    _setEntity(addOns, for: \.addOns)
    _setEntity(amount, for: \.amount)
    _setEntity(backer, for: \.backer)
    _setScalar(backerCompleted, for: \.backerCompleted)
    _setScalar(backingDetailsPageRoute, for: \.backingDetailsPageRoute)
    _setEntity(bonusAmount, for: \.bonusAmount)
    _setScalar(cancelable, for: \.cancelable)
    _setScalar(clientSecret, for: \.clientSecret)
    _setEntity(deliveryAddress, for: \.deliveryAddress)
    _setScalar(errorReason, for: \.errorReason)
    _setScalar(id, for: \.id)
    _setScalar(isLatePledge, for: \.isLatePledge)
    _setEntity(location, for: \.location)
    _setEntity(order, for: \.order)
    _setList(paymentIncrements, for: \.paymentIncrements)
    _setEntity(paymentSource, for: \.paymentSource)
    _setScalar(pledgedOn, for: \.pledgedOn)
    _setEntity(project, for: \.project)
    _setScalar(requiresAction, for: \.requiresAction)
    _setEntity(reward, for: \.reward)
    _setEntity(rewardsAmount, for: \.rewardsAmount)
    _setScalar(sequence, for: \.sequence)
    _setEntity(shippingAmount, for: \.shippingAmount)
    _setScalar(status, for: \.status)
  }
}
