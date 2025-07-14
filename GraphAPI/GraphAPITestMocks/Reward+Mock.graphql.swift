// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Reward: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Reward
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Reward>>

  public struct MockFields {
    @Field<RewardConnection>("allowedAddons") public var allowedAddons
    @Field<Money>("amount") public var amount
    @Field<ResourceAudience>("audienceData") public var audienceData
    @Field<Bool>("available") public var available
    @Field<Int>("backersCount") public var backersCount
    @Field<Money>("convertedAmount") public var convertedAmount
    @Field<String>("description") public var description
    @Field<String>("displayName") public var displayName
    @Field<GraphAPI.DateTime>("endsAt") public var endsAt
    @Field<GraphAPI.Date>("estimatedDeliveryOn") public var estimatedDeliveryOn
    @Field<GraphAPI.ID>("id") public var id
    @Field<Photo>("image") public var image
    @Field<Bool>("isMaxPledge") public var isMaxPledge
    @Field<RewardItemsConnection>("items") public var items
    @Field<Money>("latePledgeAmount") public var latePledgeAmount
    @Field<Int>("limit") public var limit
    @Field<Int>("limitPerBacker") public var limitPerBacker
    @Field<Location>("localReceiptLocation") public var localReceiptLocation
    @Field<String>("name") public var name
    @Field<Money>("pledgeAmount") public var pledgeAmount
    @Field<Bool>("postCampaignPledgingEnabled") public var postCampaignPledgingEnabled
    @Field<Project>("project") public var project
    @Field<Int>("remainingQuantity") public var remainingQuantity
    @Field<GraphQLEnum<GraphAPI.ShippingPreference>>("shippingPreference") public var shippingPreference
    @Field<[ShippingRule?]>("shippingRules") public var shippingRules
    @Field<RewardShippingRulesConnection>("shippingRulesExpanded") public var shippingRulesExpanded
    @Field<String>("shippingSummary") public var shippingSummary
    @Field<[SimpleShippingRule?]>("simpleShippingRulesExpanded") public var simpleShippingRulesExpanded
    @Field<GraphAPI.DateTime>("startsAt") public var startsAt
  }
}

public extension Mock where O == Reward {
  convenience init(
    allowedAddons: Mock<RewardConnection>? = nil,
    amount: Mock<Money>? = nil,
    audienceData: Mock<ResourceAudience>? = nil,
    available: Bool? = nil,
    backersCount: Int? = nil,
    convertedAmount: Mock<Money>? = nil,
    description: String? = nil,
    displayName: String? = nil,
    endsAt: GraphAPI.DateTime? = nil,
    estimatedDeliveryOn: GraphAPI.Date? = nil,
    id: GraphAPI.ID? = nil,
    image: Mock<Photo>? = nil,
    isMaxPledge: Bool? = nil,
    items: Mock<RewardItemsConnection>? = nil,
    latePledgeAmount: Mock<Money>? = nil,
    limit: Int? = nil,
    limitPerBacker: Int? = nil,
    localReceiptLocation: Mock<Location>? = nil,
    name: String? = nil,
    pledgeAmount: Mock<Money>? = nil,
    postCampaignPledgingEnabled: Bool? = nil,
    project: Mock<Project>? = nil,
    remainingQuantity: Int? = nil,
    shippingPreference: GraphQLEnum<GraphAPI.ShippingPreference>? = nil,
    shippingRules: [Mock<ShippingRule>?]? = nil,
    shippingRulesExpanded: Mock<RewardShippingRulesConnection>? = nil,
    shippingSummary: String? = nil,
    simpleShippingRulesExpanded: [Mock<SimpleShippingRule>?]? = nil,
    startsAt: GraphAPI.DateTime? = nil
  ) {
    self.init()
    _setEntity(allowedAddons, for: \.allowedAddons)
    _setEntity(amount, for: \.amount)
    _setEntity(audienceData, for: \.audienceData)
    _setScalar(available, for: \.available)
    _setScalar(backersCount, for: \.backersCount)
    _setEntity(convertedAmount, for: \.convertedAmount)
    _setScalar(description, for: \.description)
    _setScalar(displayName, for: \.displayName)
    _setScalar(endsAt, for: \.endsAt)
    _setScalar(estimatedDeliveryOn, for: \.estimatedDeliveryOn)
    _setScalar(id, for: \.id)
    _setEntity(image, for: \.image)
    _setScalar(isMaxPledge, for: \.isMaxPledge)
    _setEntity(items, for: \.items)
    _setEntity(latePledgeAmount, for: \.latePledgeAmount)
    _setScalar(limit, for: \.limit)
    _setScalar(limitPerBacker, for: \.limitPerBacker)
    _setEntity(localReceiptLocation, for: \.localReceiptLocation)
    _setScalar(name, for: \.name)
    _setEntity(pledgeAmount, for: \.pledgeAmount)
    _setScalar(postCampaignPledgingEnabled, for: \.postCampaignPledgingEnabled)
    _setEntity(project, for: \.project)
    _setScalar(remainingQuantity, for: \.remainingQuantity)
    _setScalar(shippingPreference, for: \.shippingPreference)
    _setList(shippingRules, for: \.shippingRules)
    _setEntity(shippingRulesExpanded, for: \.shippingRulesExpanded)
    _setScalar(shippingSummary, for: \.shippingSummary)
    _setList(simpleShippingRulesExpanded, for: \.simpleShippingRulesExpanded)
    _setScalar(startsAt, for: \.startsAt)
  }
}
