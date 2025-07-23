// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchProjectRewardsByIdQuery: GraphQLQuery {
  public static let operationName: String = "FetchProjectRewardsById"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchProjectRewardsById($projectId: Int!, $includeShippingRules: Boolean!, $includeLocalPickup: Boolean!, $includePledgeOverTime: Boolean!) { project(pid: $projectId) { __typename rewards { __typename nodes { __typename ...RewardFragment simpleShippingRulesExpanded @include(if: $includeShippingRules) { __typename cost estimatedMin estimatedMax currency locationId locationName country } } } ...PledgeOverTimeFragment @include(if: $includePledgeOverTime) } }"#,
      fragments: [LocationFragment.self, MoneyFragment.self, PledgeOverTimeFragment.self, RewardFragment.self, ShippingRuleFragment.self]
    ))

  public var projectId: Int
  public var includeShippingRules: Bool
  public var includeLocalPickup: Bool
  public var includePledgeOverTime: Bool

  public init(
    projectId: Int,
    includeShippingRules: Bool,
    includeLocalPickup: Bool,
    includePledgeOverTime: Bool
  ) {
    self.projectId = projectId
    self.includeShippingRules = includeShippingRules
    self.includeLocalPickup = includeLocalPickup
    self.includePledgeOverTime = includePledgeOverTime
  }

  public var __variables: Variables? { [
    "projectId": projectId,
    "includeShippingRules": includeShippingRules,
    "includeLocalPickup": includeLocalPickup,
    "includePledgeOverTime": includePledgeOverTime
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("project", Project?.self, arguments: ["pid": .variable("projectId")]),
    ] }

    /// Fetches a project given its slug or pid.
    public var project: Project? { __data["project"] }

    public init(
      project: Project? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "project": project._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.self)
        ]
      ))
    }

    /// Project
    ///
    /// Parent Type: `Project`
    public struct Project: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("rewards", Rewards?.self),
        .include(if: "includePledgeOverTime", .inlineFragment(IfIncludePledgeOverTime.self)),
      ] }

      /// Project rewards.
      public var rewards: Rewards? { __data["rewards"] }

      public var ifIncludePledgeOverTime: IfIncludePledgeOverTime? { _asInlineFragment() }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var pledgeOverTimeFragment: PledgeOverTimeFragment? { _toFragment() }
      }

      public init(
        rewards: Rewards? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Project.typename,
            "rewards": rewards._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.self)
          ]
        ))
      }

      /// Project.Rewards
      ///
      /// Parent Type: `ProjectRewardConnection`
      public struct Rewards: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ProjectRewardConnection }
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
              "__typename": GraphAPI.Objects.ProjectRewardConnection.typename,
              "nodes": nodes._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.Rewards.self)
            ]
          ))
        }

        /// Project.Rewards.Node
        ///
        /// Parent Type: `Reward`
        public struct Node: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Reward }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(RewardFragment.self),
            .include(if: "includeShippingRules", .field("simpleShippingRulesExpanded", [SimpleShippingRulesExpanded?].self)),
          ] }

          /// Simple shipping rules expanded as a faster alternative to shippingRulesExpanded since connection type is slow
          public var simpleShippingRulesExpanded: [SimpleShippingRulesExpanded?]? { __data["simpleShippingRulesExpanded"] }
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
          public var description: String { __data["description"] }
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
          /// Items in the reward.
          public var items: Items? { __data["items"] }
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
          /// The project
          public var project: Project? { __data["project"] }
          /// Remaining reward quantity.
          public var remainingQuantity: Int? { __data["remainingQuantity"] }
          /// Shipping preference for this reward
          public var shippingPreference: GraphQLEnum<GraphAPI.ShippingPreference>? { __data["shippingPreference"] }
          /// A shipping summary
          public var shippingSummary: String? { __data["shippingSummary"] }
          /// Shipping rules defined by the creator for this reward
          public var shippingRules: [ShippingRule?]? { __data["shippingRules"] }
          /// When the reward is scheduled to start
          public var startsAt: GraphAPI.DateTime? { __data["startsAt"] }
          /// The reward image.
          public var image: Image? { __data["image"] }
          /// Data related to who can view/access this reward
          public var audienceData: AudienceData { __data["audienceData"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var rewardFragment: RewardFragment { _toFragment() }
          }

          public init(
            simpleShippingRulesExpanded: [SimpleShippingRulesExpanded?]? = nil,
            amount: Amount,
            backersCount: Int? = nil,
            convertedAmount: ConvertedAmount,
            allowedAddons: AllowedAddons,
            description: String,
            displayName: String,
            endsAt: GraphAPI.DateTime? = nil,
            estimatedDeliveryOn: GraphAPI.Date? = nil,
            id: GraphAPI.ID,
            isMaxPledge: Bool,
            available: Bool,
            items: Items? = nil,
            limit: Int? = nil,
            limitPerBacker: Int? = nil,
            localReceiptLocation: LocalReceiptLocation? = nil,
            name: String? = nil,
            pledgeAmount: PledgeAmount,
            latePledgeAmount: LatePledgeAmount,
            postCampaignPledgingEnabled: Bool,
            project: Project? = nil,
            remainingQuantity: Int? = nil,
            shippingPreference: GraphQLEnum<GraphAPI.ShippingPreference>? = nil,
            shippingSummary: String? = nil,
            shippingRules: [ShippingRule?]? = nil,
            startsAt: GraphAPI.DateTime? = nil,
            image: Image? = nil,
            audienceData: AudienceData
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.Reward.typename,
                "simpleShippingRulesExpanded": simpleShippingRulesExpanded._fieldData,
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
                "items": items._fieldData,
                "limit": limit,
                "limitPerBacker": limitPerBacker,
                "localReceiptLocation": localReceiptLocation._fieldData,
                "name": name,
                "pledgeAmount": pledgeAmount._fieldData,
                "latePledgeAmount": latePledgeAmount._fieldData,
                "postCampaignPledgingEnabled": postCampaignPledgingEnabled,
                "project": project._fieldData,
                "remainingQuantity": remainingQuantity,
                "shippingPreference": shippingPreference,
                "shippingSummary": shippingSummary,
                "shippingRules": shippingRules._fieldData,
                "startsAt": startsAt,
                "image": image._fieldData,
                "audienceData": audienceData._fieldData,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.Rewards.Node.self),
                ObjectIdentifier(RewardFragment.self)
              ]
            ))
          }

          /// Project.Rewards.Node.SimpleShippingRulesExpanded
          ///
          /// Parent Type: `SimpleShippingRule`
          public struct SimpleShippingRulesExpanded: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.SimpleShippingRule }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("cost", String?.self),
              .field("estimatedMin", String?.self),
              .field("estimatedMax", String?.self),
              .field("currency", String?.self),
              .field("locationId", GraphAPI.ID?.self),
              .field("locationName", String?.self),
              .field("country", String.self),
            ] }

            public var cost: String? { __data["cost"] }
            public var estimatedMin: String? { __data["estimatedMin"] }
            public var estimatedMax: String? { __data["estimatedMax"] }
            public var currency: String? { __data["currency"] }
            public var locationId: GraphAPI.ID? { __data["locationId"] }
            public var locationName: String? { __data["locationName"] }
            public var country: String { __data["country"] }

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
                  ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.Rewards.Node.SimpleShippingRulesExpanded.self)
                ]
              ))
            }
          }

          /// Project.Rewards.Node.Amount
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
                  ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.Rewards.Node.Amount.self),
                  ObjectIdentifier(RewardFragment.Amount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          /// Project.Rewards.Node.ConvertedAmount
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
                  ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.Rewards.Node.ConvertedAmount.self),
                  ObjectIdentifier(RewardFragment.ConvertedAmount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          public typealias AllowedAddons = RewardFragment.AllowedAddons

          public typealias Items = RewardFragment.Items

          /// Project.Rewards.Node.LocalReceiptLocation
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
                  ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.Rewards.Node.LocalReceiptLocation.self),
                  ObjectIdentifier(RewardFragment.LocalReceiptLocation.self),
                  ObjectIdentifier(LocationFragment.self)
                ]
              ))
            }
          }

          /// Project.Rewards.Node.PledgeAmount
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
                  ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.Rewards.Node.PledgeAmount.self),
                  ObjectIdentifier(RewardFragment.PledgeAmount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          /// Project.Rewards.Node.LatePledgeAmount
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
                  ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.Rewards.Node.LatePledgeAmount.self),
                  ObjectIdentifier(RewardFragment.LatePledgeAmount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          public typealias Project = RewardFragment.Project

          /// Project.Rewards.Node.ShippingRule
          ///
          /// Parent Type: `ShippingRule`
          public struct ShippingRule: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ShippingRule }

            /// The shipping cost for this location.
            public var cost: Cost? { __data["cost"] }
            public var id: GraphAPI.ID { __data["id"] }
            /// The shipping location to which the rule pertains.
            public var location: Location { __data["location"] }
            /// The estimated minimum shipping cost
            public var estimatedMin: EstimatedMin? { __data["estimatedMin"] }
            /// The estimated maximum shipping cost
            public var estimatedMax: EstimatedMax? { __data["estimatedMax"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var shippingRuleFragment: ShippingRuleFragment { _toFragment() }
            }

            public init(
              cost: Cost? = nil,
              id: GraphAPI.ID,
              location: Location,
              estimatedMin: EstimatedMin? = nil,
              estimatedMax: EstimatedMax? = nil
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.ShippingRule.typename,
                  "cost": cost._fieldData,
                  "id": id,
                  "location": location._fieldData,
                  "estimatedMin": estimatedMin._fieldData,
                  "estimatedMax": estimatedMax._fieldData,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.Rewards.Node.ShippingRule.self),
                  ObjectIdentifier(RewardFragment.ShippingRule.self),
                  ObjectIdentifier(ShippingRuleFragment.self)
                ]
              ))
            }

            /// Project.Rewards.Node.ShippingRule.Cost
            ///
            /// Parent Type: `Money`
            public struct Cost: GraphAPI.SelectionSet {
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
                    ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.Rewards.Node.ShippingRule.Cost.self),
                    ObjectIdentifier(ShippingRuleFragment.Cost.self),
                    ObjectIdentifier(MoneyFragment.self)
                  ]
                ))
              }
            }

            /// Project.Rewards.Node.ShippingRule.Location
            ///
            /// Parent Type: `Location`
            public struct Location: GraphAPI.SelectionSet {
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
                    ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.Rewards.Node.ShippingRule.Location.self),
                    ObjectIdentifier(ShippingRuleFragment.Location.self),
                    ObjectIdentifier(LocationFragment.self)
                  ]
                ))
              }
            }

            public typealias EstimatedMin = ShippingRuleFragment.EstimatedMin

            public typealias EstimatedMax = ShippingRuleFragment.EstimatedMax
          }

          public typealias Image = RewardFragment.Image

          public typealias AudienceData = RewardFragment.AudienceData
        }
      }

      /// Project.IfIncludePledgeOverTime
      ///
      /// Parent Type: `Project`
      public struct IfIncludePledgeOverTime: GraphAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = FetchProjectRewardsByIdQuery.Data.Project
        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
        public static var __selections: [ApolloAPI.Selection] { [
          .fragment(PledgeOverTimeFragment.self),
        ] }

        /// Project rewards.
        public var rewards: Rewards? { __data["rewards"] }
        /// Whether a project is enrolled in plot
        public var isPledgeOverTimeAllowed: Bool { __data["isPledgeOverTimeAllowed"] }
        /// Backer-facing summary of when the incremental charges will occur
        public var pledgeOverTimeCollectionPlanChargeExplanation: String? { __data["pledgeOverTimeCollectionPlanChargeExplanation"] }
        /// Quick summary of the amount of increments pledges will be spread over
        public var pledgeOverTimeCollectionPlanChargedAsNPayments: String? { __data["pledgeOverTimeCollectionPlanChargedAsNPayments"] }
        /// Backer-facing short summary of this project's number of payment increments to split over
        public var pledgeOverTimeCollectionPlanShortPitch: String? { __data["pledgeOverTimeCollectionPlanShortPitch"] }
        /// The minimum pledge amount to be eligible for PLOT, localized to the project currency and backer language
        public var pledgeOverTimeMinimumExplanation: String? { __data["pledgeOverTimeMinimumExplanation"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var pledgeOverTimeFragment: PledgeOverTimeFragment { _toFragment() }
        }

        public init(
          rewards: Rewards? = nil,
          isPledgeOverTimeAllowed: Bool,
          pledgeOverTimeCollectionPlanChargeExplanation: String? = nil,
          pledgeOverTimeCollectionPlanChargedAsNPayments: String? = nil,
          pledgeOverTimeCollectionPlanShortPitch: String? = nil,
          pledgeOverTimeMinimumExplanation: String? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Project.typename,
              "rewards": rewards._fieldData,
              "isPledgeOverTimeAllowed": isPledgeOverTimeAllowed,
              "pledgeOverTimeCollectionPlanChargeExplanation": pledgeOverTimeCollectionPlanChargeExplanation,
              "pledgeOverTimeCollectionPlanChargedAsNPayments": pledgeOverTimeCollectionPlanChargedAsNPayments,
              "pledgeOverTimeCollectionPlanShortPitch": pledgeOverTimeCollectionPlanShortPitch,
              "pledgeOverTimeMinimumExplanation": pledgeOverTimeMinimumExplanation,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.self),
              ObjectIdentifier(FetchProjectRewardsByIdQuery.Data.Project.IfIncludePledgeOverTime.self),
              ObjectIdentifier(PledgeOverTimeFragment.self)
            ]
          ))
        }
      }
    }
  }
}
