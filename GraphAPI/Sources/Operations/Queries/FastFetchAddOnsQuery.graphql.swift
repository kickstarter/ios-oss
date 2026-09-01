// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FastFetchAddOnsQuery: GraphQLQuery {
  public static let operationName: String = "FastFetchAddOns"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FastFetchAddOns($baseRewardId: ID!, $country: CountryCode!) { reward(id: $baseRewardId) { __typename displayableAddons { __typename nodes { __typename ...RewardFragment ...RewardImageFragment ...RewardItemsFragment shippingForLocation(countryCode: $country) { __typename shippingRule { __typename ...SimpleShippingRuleFragment } } } } } }"#,
      fragments: [LocationFragment.self, MoneyFragment.self, RewardFragment.self, RewardImageFragment.self, RewardItemsFragment.self, SimpleShippingRuleFragment.self]
    ))

  public var baseRewardId: ID
  public var country: GraphQLEnum<CountryCode>

  public init(
    baseRewardId: ID,
    country: GraphQLEnum<CountryCode>
  ) {
    self.baseRewardId = baseRewardId
    self.country = country
  }

  public var __variables: Variables? { [
    "baseRewardId": baseRewardId,
    "country": country
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("reward", Reward?.self, arguments: ["id": .variable("baseRewardId")]),
    ] }

    public var reward: Reward? { __data["reward"] }

    public init(
      reward: Reward? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "reward": reward._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(FastFetchAddOnsQuery.Data.self)
        ]
      ))
    }

    /// Reward
    ///
    /// Parent Type: `Reward`
    public struct Reward: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Reward }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("displayableAddons", DisplayableAddons.self),
      ] }

      /// The same as allowed_addons but with an additional scope that filters out addons with a start date that falls in the future
      ///
      public var displayableAddons: DisplayableAddons { __data["displayableAddons"] }

      public init(
        displayableAddons: DisplayableAddons
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Reward.typename,
            "displayableAddons": displayableAddons._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FastFetchAddOnsQuery.Data.Reward.self)
          ]
        ))
      }

      /// Reward.DisplayableAddons
      ///
      /// Parent Type: `RewardConnection`
      public struct DisplayableAddons: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RewardConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        public init(
          nodes: [Node?]? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.RewardConnection.typename,
              "nodes": nodes._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FastFetchAddOnsQuery.Data.Reward.DisplayableAddons.self)
            ]
          ))
        }

        /// Reward.DisplayableAddons.Node
        ///
        /// Parent Type: `Reward`
        public struct Node: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Reward }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("shippingForLocation", ShippingForLocation.self, arguments: ["countryCode": .variable("country")]),
            .fragment(RewardFragment.self),
            .fragment(RewardImageFragment.self),
            .fragment(RewardItemsFragment.self),
          ] }

          /// Shipping availability and matching rule for a reward at a given country.
          public var shippingForLocation: ShippingForLocation { __data["shippingForLocation"] }
          /// Amount for claiming this reward.
          public var amount: Amount { __data["amount"] }
          /// count of backers for this reward
          public var backersCount: Int? { __data["backersCount"] }
          /// Amount for claiming this reward, in the current user's chosen currency
          public var convertedAmount: ConvertedAmount { __data["convertedAmount"] }
          /// Add-ons which can be combined with this reward.
          /// Uses creator preferences and shipping rules to determine allow-ability.
          /// Inclusion in this list does not necessarily indicate that the add-on is available for backing.
          ///
          public var allowedAddons: AllowedAddons { __data["allowedAddons"] }
          /// A reward description.
          public var description: String? { __data["description"] }
          /// A reward's title plus the amount, or a default title (the reward amount) if it doesn't have a title.
          public var displayName: String { __data["displayName"] }
          /// When the reward is scheduled to end in seconds
          public var endsAt: GraphAPI.DateTime? { __data["endsAt"] }
          /// Estimated delivery day.
          public var estimatedDeliveryOn: GraphAPI.Date? { __data["estimatedDeliveryOn"] }
          public var id: GraphAPI.ID { __data["id"] }
          /// Does reward amount meet or exceed maximum pledge for the project
          public var isMaxPledge: Bool { __data["isMaxPledge"] }
          /// Whether or not the reward is available for new pledges
          public var available: Bool { __data["available"] }
          /// Whether or not the reward is featured
          public var featured: Bool { __data["featured"] }
          /// A reward limit.
          public var limit: Int? { __data["limit"] }
          /// Per backer reward limit.
          public var limitPerBacker: Int? { __data["limitPerBacker"] }
          /// Where the reward can be locally received if local receipt is selected as the shipping preference
          public var localReceiptLocation: LocalReceiptLocation? { __data["localReceiptLocation"] }
          /// A reward title.
          public var name: String? { __data["name"] }
          /// Amount for claiming this reward during the campaign.
          public var pledgeAmount: PledgeAmount { __data["pledgeAmount"] }
          /// Amount for claiming this reward after the campaign.
          public var latePledgeAmount: LatePledgeAmount { __data["latePledgeAmount"] }
          /// Is this reward available for post-campaign pledges?
          public var postCampaignPledgingEnabled: Bool { __data["postCampaignPledgingEnabled"] }
          /// Remaining reward quantity.
          public var remainingQuantity: Int? { __data["remainingQuantity"] }
          /// Shipping preference for this reward
          public var shippingPreference: GraphQLEnum<GraphAPI.ShippingPreference>? { __data["shippingPreference"] }
          /// A shipping summary
          public var shippingSummary: String? { __data["shippingSummary"] }
          /// When the reward is scheduled to start
          public var startsAt: GraphAPI.DateTime? { __data["startsAt"] }
          /// Data related to who can view/access this reward
          public var audienceData: AudienceData { __data["audienceData"] }
          /// The reward image.
          public var image: Image? { __data["image"] }
          /// The project
          public var project: Project? { __data["project"] }
          /// Items in the reward.
          public var items: Items? { __data["items"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var rewardFragment: RewardFragment { _toFragment() }
            public var rewardImageFragment: RewardImageFragment { _toFragment() }
            public var rewardItemsFragment: RewardItemsFragment { _toFragment() }
          }

          public init(
            shippingForLocation: ShippingForLocation,
            amount: Amount,
            backersCount: Int? = nil,
            convertedAmount: ConvertedAmount,
            allowedAddons: AllowedAddons,
            description: String? = nil,
            displayName: String,
            endsAt: GraphAPI.DateTime? = nil,
            estimatedDeliveryOn: GraphAPI.Date? = nil,
            id: GraphAPI.ID,
            isMaxPledge: Bool,
            available: Bool,
            featured: Bool,
            limit: Int? = nil,
            limitPerBacker: Int? = nil,
            localReceiptLocation: LocalReceiptLocation? = nil,
            name: String? = nil,
            pledgeAmount: PledgeAmount,
            latePledgeAmount: LatePledgeAmount,
            postCampaignPledgingEnabled: Bool,
            remainingQuantity: Int? = nil,
            shippingPreference: GraphQLEnum<GraphAPI.ShippingPreference>? = nil,
            shippingSummary: String? = nil,
            startsAt: GraphAPI.DateTime? = nil,
            audienceData: AudienceData,
            image: Image? = nil,
            project: Project? = nil,
            items: Items? = nil
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.Reward.typename,
                "shippingForLocation": shippingForLocation._fieldData,
                "amount": amount._fieldData,
                "backersCount": backersCount,
                "convertedAmount": convertedAmount._fieldData,
                "allowedAddons": allowedAddons._fieldData,
                "description": description,
                "displayName": displayName,
                "endsAt": endsAt,
                "estimatedDeliveryOn": estimatedDeliveryOn,
                "id": id,
                "isMaxPledge": isMaxPledge,
                "available": available,
                "featured": featured,
                "limit": limit,
                "limitPerBacker": limitPerBacker,
                "localReceiptLocation": localReceiptLocation._fieldData,
                "name": name,
                "pledgeAmount": pledgeAmount._fieldData,
                "latePledgeAmount": latePledgeAmount._fieldData,
                "postCampaignPledgingEnabled": postCampaignPledgingEnabled,
                "remainingQuantity": remainingQuantity,
                "shippingPreference": shippingPreference,
                "shippingSummary": shippingSummary,
                "startsAt": startsAt,
                "audienceData": audienceData._fieldData,
                "image": image._fieldData,
                "project": project._fieldData,
                "items": items._fieldData,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FastFetchAddOnsQuery.Data.Reward.DisplayableAddons.Node.self),
                ObjectIdentifier(RewardFragment.self),
                ObjectIdentifier(RewardImageFragment.self),
                ObjectIdentifier(RewardItemsFragment.self)
              ]
            ))
          }

          /// Reward.DisplayableAddons.Node.ShippingForLocation
          ///
          /// Parent Type: `ShippingForLocation`
          public struct ShippingForLocation: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ShippingForLocation }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("shippingRule", ShippingRule?.self),
            ] }

            /// The shipping rule matching the given country, if one exists.
            public var shippingRule: ShippingRule? { __data["shippingRule"] }

            public init(
              shippingRule: ShippingRule? = nil
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.ShippingForLocation.typename,
                  "shippingRule": shippingRule._fieldData,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(FastFetchAddOnsQuery.Data.Reward.DisplayableAddons.Node.ShippingForLocation.self)
                ]
              ))
            }

            /// Reward.DisplayableAddons.Node.ShippingForLocation.ShippingRule
            ///
            /// Parent Type: `SimpleShippingRule`
            public struct ShippingRule: GraphAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.SimpleShippingRule }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(SimpleShippingRuleFragment.self),
              ] }

              public var cost: String? { __data["cost"] }
              public var estimatedMin: String? { __data["estimatedMin"] }
              public var estimatedMax: String? { __data["estimatedMax"] }
              public var currency: String? { __data["currency"] }
              public var locationId: GraphAPI.ID? { __data["locationId"] }
              public var locationName: String? { __data["locationName"] }
              public var country: String { __data["country"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var simpleShippingRuleFragment: SimpleShippingRuleFragment { _toFragment() }
              }

              public init(
                cost: String? = nil,
                estimatedMin: String? = nil,
                estimatedMax: String? = nil,
                currency: String? = nil,
                locationId: GraphAPI.ID? = nil,
                locationName: String? = nil,
                country: String
              ) {
                self.init(_dataDict: DataDict(
                  data: [
                    "__typename": GraphAPI.Objects.SimpleShippingRule.typename,
                    "cost": cost,
                    "estimatedMin": estimatedMin,
                    "estimatedMax": estimatedMax,
                    "currency": currency,
                    "locationId": locationId,
                    "locationName": locationName,
                    "country": country,
                  ],
                  fulfilledFragments: [
                    ObjectIdentifier(FastFetchAddOnsQuery.Data.Reward.DisplayableAddons.Node.ShippingForLocation.ShippingRule.self),
                    ObjectIdentifier(SimpleShippingRuleFragment.self)
                  ]
                ))
              }
            }
          }

          /// Reward.DisplayableAddons.Node.Amount
          ///
          /// Parent Type: `Money`
          public struct Amount: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }

            /// Floating-point numeric value of monetary amount represented as a string
            public var amount: String? { __data["amount"] }
            /// Currency of the monetary amount
            public var currency: GraphQLEnum<GraphAPI.CurrencyCode>? { __data["currency"] }
            /// Symbol of the currency in which the monetary amount appears
            public var symbol: String? { __data["symbol"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var moneyFragment: MoneyFragment { _toFragment() }
            }

            public init(
              amount: String? = nil,
              currency: GraphQLEnum<GraphAPI.CurrencyCode>? = nil,
              symbol: String? = nil
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.Money.typename,
                  "amount": amount,
                  "currency": currency,
                  "symbol": symbol,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(FastFetchAddOnsQuery.Data.Reward.DisplayableAddons.Node.Amount.self),
                  ObjectIdentifier(RewardFragment.Amount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          /// Reward.DisplayableAddons.Node.ConvertedAmount
          ///
          /// Parent Type: `Money`
          public struct ConvertedAmount: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }

            /// Floating-point numeric value of monetary amount represented as a string
            public var amount: String? { __data["amount"] }
            /// Currency of the monetary amount
            public var currency: GraphQLEnum<GraphAPI.CurrencyCode>? { __data["currency"] }
            /// Symbol of the currency in which the monetary amount appears
            public var symbol: String? { __data["symbol"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var moneyFragment: MoneyFragment { _toFragment() }
            }

            public init(
              amount: String? = nil,
              currency: GraphQLEnum<GraphAPI.CurrencyCode>? = nil,
              symbol: String? = nil
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.Money.typename,
                  "amount": amount,
                  "currency": currency,
                  "symbol": symbol,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(FastFetchAddOnsQuery.Data.Reward.DisplayableAddons.Node.ConvertedAmount.self),
                  ObjectIdentifier(RewardFragment.ConvertedAmount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          public typealias AllowedAddons = RewardFragment.AllowedAddons

          /// Reward.DisplayableAddons.Node.LocalReceiptLocation
          ///
          /// Parent Type: `Location`
          public struct LocalReceiptLocation: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Location }

            /// The country code.
            public var country: String { __data["country"] }
            /// The localized country name.
            public var countryName: String? { __data["countryName"] }
            /// The displayable name. It includes the state code for US cities. ex: 'Seattle, WA'
            public var displayableName: String { __data["displayableName"] }
            public var id: GraphAPI.ID { __data["id"] }
            /// The localized name
            public var name: String { __data["name"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var locationFragment: LocationFragment { _toFragment() }
            }

            public init(
              country: String,
              countryName: String? = nil,
              displayableName: String,
              id: GraphAPI.ID,
              name: String
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.Location.typename,
                  "country": country,
                  "countryName": countryName,
                  "displayableName": displayableName,
                  "id": id,
                  "name": name,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(FastFetchAddOnsQuery.Data.Reward.DisplayableAddons.Node.LocalReceiptLocation.self),
                  ObjectIdentifier(RewardFragment.LocalReceiptLocation.self),
                  ObjectIdentifier(LocationFragment.self)
                ]
              ))
            }
          }

          /// Reward.DisplayableAddons.Node.PledgeAmount
          ///
          /// Parent Type: `Money`
          public struct PledgeAmount: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }

            /// Floating-point numeric value of monetary amount represented as a string
            public var amount: String? { __data["amount"] }
            /// Currency of the monetary amount
            public var currency: GraphQLEnum<GraphAPI.CurrencyCode>? { __data["currency"] }
            /// Symbol of the currency in which the monetary amount appears
            public var symbol: String? { __data["symbol"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var moneyFragment: MoneyFragment { _toFragment() }
            }

            public init(
              amount: String? = nil,
              currency: GraphQLEnum<GraphAPI.CurrencyCode>? = nil,
              symbol: String? = nil
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.Money.typename,
                  "amount": amount,
                  "currency": currency,
                  "symbol": symbol,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(FastFetchAddOnsQuery.Data.Reward.DisplayableAddons.Node.PledgeAmount.self),
                  ObjectIdentifier(RewardFragment.PledgeAmount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          /// Reward.DisplayableAddons.Node.LatePledgeAmount
          ///
          /// Parent Type: `Money`
          public struct LatePledgeAmount: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }

            /// Floating-point numeric value of monetary amount represented as a string
            public var amount: String? { __data["amount"] }
            /// Currency of the monetary amount
            public var currency: GraphQLEnum<GraphAPI.CurrencyCode>? { __data["currency"] }
            /// Symbol of the currency in which the monetary amount appears
            public var symbol: String? { __data["symbol"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var moneyFragment: MoneyFragment { _toFragment() }
            }

            public init(
              amount: String? = nil,
              currency: GraphQLEnum<GraphAPI.CurrencyCode>? = nil,
              symbol: String? = nil
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.Money.typename,
                  "amount": amount,
                  "currency": currency,
                  "symbol": symbol,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(FastFetchAddOnsQuery.Data.Reward.DisplayableAddons.Node.LatePledgeAmount.self),
                  ObjectIdentifier(RewardFragment.LatePledgeAmount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          public typealias AudienceData = RewardFragment.AudienceData

          public typealias Image = RewardImageFragment.Image

          public typealias Project = RewardItemsFragment.Project

          public typealias Items = RewardItemsFragment.Items
        }
      }
    }
  }
}
