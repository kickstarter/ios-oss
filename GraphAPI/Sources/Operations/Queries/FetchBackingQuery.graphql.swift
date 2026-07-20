// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchBackingQuery: GraphQLQuery {
  public static let operationName: String = "FetchBacking"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchBacking($id: ID!, $includeLocalPickup: Boolean!) { backing(id: $id) { __typename addOns { __typename nodes { __typename ...RewardFragment } } ...BackingFragment project { __typename ...ProjectFragment } paymentIncrements { __typename ...PaymentIncrementFragment } } }"#,
      fragments: [BackingFragment.self, CategoryFragment.self, CountryFragment.self, ExtendedProjectPropertiesFragment.self, LastWaveFragment.self, LocationFragment.self, MoneyFragment.self, NoRewardRewardFragment.self, OrderFragment.self, PaymentIncrementFragment.self, PaymentSourceFragment.self, PledgeManagerFragment.self, PledgeOverTimeFragment.self, ProjectDatesFragment.self, ProjectFragment.self, ProjectStatsFragment.self, ProjectVideoFragment.self, PublicUserFragment.self, RewardFragment.self, SimpleShippingRulesExpandedFragment.self]
    ))

  public var id: ID
  public var includeLocalPickup: Bool

  public init(
    id: ID,
    includeLocalPickup: Bool
  ) {
    self.id = id
    self.includeLocalPickup = includeLocalPickup
  }

  public var __variables: Variables? { [
    "id": id,
    "includeLocalPickup": includeLocalPickup
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("backing", Backing?.self, arguments: ["id": .variable("id")]),
    ] }

    /// Fetches a backing given its id.
    public var backing: Backing? { __data["backing"] }

    public init(
      backing: Backing? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "backing": backing._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(FetchBackingQuery.Data.self)
        ]
      ))
    }

    /// Backing
    ///
    /// Parent Type: `Backing`
    public struct Backing: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Backing }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("addOns", AddOns?.self),
        .field("project", Project?.self),
        .field("paymentIncrements", [PaymentIncrement]?.self),
        .fragment(BackingFragment.self),
      ] }

      /// The add-ons that the backer selected
      public var addOns: AddOns? { __data["addOns"] }
      /// The project
      public var project: Project? { __data["project"] }
      /// Scheduled incremental payments
      public var paymentIncrements: [PaymentIncrement]? { __data["paymentIncrements"] }
      /// Total amount pledged by the backer to the project, including shipping.
      public var amount: Amount { __data["amount"] }
      /// The backer
      public var backer: Backer? { __data["backer"] }
      /// If the backer_completed_at is set or not
      public var backerCompleted: Bool { __data["backerCompleted"] }
      /// Extra amount the backer pledged on top of the minimum.
      public var bonusAmount: BonusAmount { __data["bonusAmount"] }
      /// If the backing can be cancelled
      public var cancelable: Bool { __data["cancelable"] }
      /// Payment source used on a backing.
      public var paymentSource: PaymentSource? { __data["paymentSource"] }
      public var id: GraphAPI.ID { __data["id"] }
      /// Whether or not the backing is a late pledge
      public var isLatePledge: Bool { __data["isLatePledge"] }
      /// The backing location.
      public var location: Location? { __data["location"] }
      /// The order associated with the backing
      public var order: Order? { __data["order"] }
      /// When the backing was created
      public var pledgedOn: GraphAPI.DateTime? { __data["pledgedOn"] }
      /// The reward the backer is expecting
      public var reward: Reward? { __data["reward"] }
      /// Amount pledged for all rewards, the sum off all minimums, excluding shipping
      public var rewardsAmount: RewardsAmount { __data["rewardsAmount"] }
      /// Sequence of the backing
      public var sequence: Int? { __data["sequence"] }
      /// Shipping amount for the rewards chosen by the backer for their location
      public var shippingAmount: ShippingAmount? { __data["shippingAmount"] }
      /// The status of a backing
      public var status: GraphQLEnum<GraphAPI.BackingState> { __data["status"] }
      /// URL/path for the backing details page
      public var backingDetailsPageRoute: String { __data["backingDetailsPageRoute"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var backingFragment: BackingFragment { _toFragment() }
      }

      public init(
        addOns: AddOns? = nil,
        project: Project? = nil,
        paymentIncrements: [PaymentIncrement]? = nil,
        amount: Amount,
        backer: Backer? = nil,
        backerCompleted: Bool,
        bonusAmount: BonusAmount,
        cancelable: Bool,
        paymentSource: PaymentSource? = nil,
        id: GraphAPI.ID,
        isLatePledge: Bool,
        location: Location? = nil,
        order: Order? = nil,
        pledgedOn: GraphAPI.DateTime? = nil,
        reward: Reward? = nil,
        rewardsAmount: RewardsAmount,
        sequence: Int? = nil,
        shippingAmount: ShippingAmount? = nil,
        status: GraphQLEnum<GraphAPI.BackingState>,
        backingDetailsPageRoute: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Backing.typename,
            "addOns": addOns._fieldData,
            "project": project._fieldData,
            "paymentIncrements": paymentIncrements._fieldData,
            "amount": amount._fieldData,
            "backer": backer._fieldData,
            "backerCompleted": backerCompleted,
            "bonusAmount": bonusAmount._fieldData,
            "cancelable": cancelable,
            "paymentSource": paymentSource._fieldData,
            "id": id,
            "isLatePledge": isLatePledge,
            "location": location._fieldData,
            "order": order._fieldData,
            "pledgedOn": pledgedOn,
            "reward": reward._fieldData,
            "rewardsAmount": rewardsAmount._fieldData,
            "sequence": sequence,
            "shippingAmount": shippingAmount._fieldData,
            "status": status,
            "backingDetailsPageRoute": backingDetailsPageRoute,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FetchBackingQuery.Data.Backing.self),
            ObjectIdentifier(BackingFragment.self)
          ]
        ))
      }

      /// Backing.AddOns
      ///
      /// Parent Type: `RewardTotalCountConnection`
      public struct AddOns: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RewardTotalCountConnection }
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
              "__typename": GraphAPI.Objects.RewardTotalCountConnection.typename,
              "nodes": nodes._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchBackingQuery.Data.Backing.AddOns.self)
            ]
          ))
        }

        /// Backing.AddOns.Node
        ///
        /// Parent Type: `Reward`
        public struct Node: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Reward }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(RewardFragment.self),
          ] }

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
            startsAt: GraphAPI.DateTime? = nil,
            image: Image? = nil,
            audienceData: AudienceData
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.Reward.typename,
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
                "startsAt": startsAt,
                "image": image._fieldData,
                "audienceData": audienceData._fieldData,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchBackingQuery.Data.Backing.AddOns.Node.self),
                ObjectIdentifier(RewardFragment.self)
              ]
            ))
          }

          /// Backing.AddOns.Node.Amount
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
                  ObjectIdentifier(FetchBackingQuery.Data.Backing.AddOns.Node.Amount.self),
                  ObjectIdentifier(RewardFragment.Amount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          /// Backing.AddOns.Node.ConvertedAmount
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
                  ObjectIdentifier(FetchBackingQuery.Data.Backing.AddOns.Node.ConvertedAmount.self),
                  ObjectIdentifier(RewardFragment.ConvertedAmount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          public typealias AllowedAddons = RewardFragment.AllowedAddons

          public typealias Items = RewardFragment.Items

          /// Backing.AddOns.Node.LocalReceiptLocation
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
                  ObjectIdentifier(FetchBackingQuery.Data.Backing.AddOns.Node.LocalReceiptLocation.self),
                  ObjectIdentifier(RewardFragment.LocalReceiptLocation.self),
                  ObjectIdentifier(LocationFragment.self)
                ]
              ))
            }
          }

          /// Backing.AddOns.Node.PledgeAmount
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
                  ObjectIdentifier(FetchBackingQuery.Data.Backing.AddOns.Node.PledgeAmount.self),
                  ObjectIdentifier(RewardFragment.PledgeAmount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          /// Backing.AddOns.Node.LatePledgeAmount
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
                  ObjectIdentifier(FetchBackingQuery.Data.Backing.AddOns.Node.LatePledgeAmount.self),
                  ObjectIdentifier(RewardFragment.LatePledgeAmount.self),
                  ObjectIdentifier(MoneyFragment.self)
                ]
              ))
            }
          }

          public typealias Project = RewardFragment.Project

          public typealias Image = RewardFragment.Image

          public typealias AudienceData = RewardFragment.AudienceData
        }
      }

      /// Backing.Project
      ///
      /// Parent Type: `Project`
      public struct Project: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ProjectFragment.self),
        ] }

        /// Available card types.
        public var availableCardTypes: [GraphQLEnum<GraphAPI.CreditCardTypes>] { __data["availableCardTypes"] }
        /// The project's category.
        public var category: Category? { __data["category"] }
        /// True if the current user can comment (considers restrictions)
        public var canComment: Bool { __data["canComment"] }
        /// The project's country
        public var country: Country { __data["country"] }
        /// The project's creator.
        public var creator: Creator? { __data["creator"] }
        /// A short description of the project.
        public var description: String { __data["description"] }
        /// The project's primary image.
        public var image: Image? { __data["image"] }
        /// Whether or not this is a Kickstarter-featured project.
        public var isProjectWeLove: Bool { __data["isProjectWeLove"] }
        /// Is the current user watching this project?
        public var isWatched: Bool { __data["isWatched"] }
        /// The project has launched
        public var isLaunched: Bool { __data["isLaunched"] }
        /// Is this project currently accepting post-campaign pledges?
        public var isInPostCampaignPledgingPhase: Bool { __data["isInPostCampaignPledgingPhase"] }
        /// The last checkout_wave, if there is one
        public var lastWave: LastWave? { __data["lastWave"] }
        /// Where the project is based.
        public var location: Location? { __data["location"] }
        /// The max pledge amount for a single reward tier.
        public var maxPledge: Int { __data["maxPledge"] }
        /// The min pledge amount for a single reward tier.
        public var minPledge: Int { __data["minPledge"] }
        /// The project's name.
        public var name: String { __data["name"] }
        /// The project's pid.
        public var pid: Int { __data["pid"] }
        /// The project's pledge manager
        public var pledgeManager: PledgeManager? { __data["pledgeManager"] }
        /// Is this project configured for post-campaign pledges?
        public var postCampaignPledgingEnabled: Bool { __data["postCampaignPledgingEnabled"] }
        /// Whether a project has activated prelaunch (can return true if project has been launched)
        public var prelaunchActivated: Bool { __data["prelaunchActivated"] }
        /// URL for redeeming the backing
        public var redemptionPageUrl: String { __data["redemptionPageUrl"] }
        /// Is this project configured so that events should be triggered for Meta's Conversions API?
        public var sendMetaCapiEvents: Bool { __data["sendMetaCapiEvents"] }
        /// The project's unique URL identifier.
        public var slug: String { __data["slug"] }
        /// The project's current state in the state machine.
        public var state: GraphQLEnum<GraphAPI.ProjectState> { __data["state"] }
        /// Tags project has been tagged with
        public var tags: [Tag?] { __data["tags"] }
        /// A URL to the project's page.
        public var url: String { __data["url"] }
        /// A project video.
        public var video: Video? { __data["video"] }
        /// Number of watchers a project has.
        public var watchesCount: Int? { __data["watchesCount"] }
        public var aiDisclosure: AiDisclosure? { __data["aiDisclosure"] }
        /// The environmental commitments of the project.
        public var environmentalCommitments: [EnvironmentalCommitment?]? { __data["environmentalCommitments"] }
        /// List of FAQs of a project
        public var faqs: Faqs? { __data["faqs"] }
        /// The text of the currently applied project notice, empty if there is no notice
        public var projectNotice: String? { __data["projectNotice"] }
        /// Potential hurdles to project completion.
        public var risks: String { __data["risks"] }
        /// The story behind the project, parsed for presentation.
        public var story: GraphAPI.HTML { __data["story"] }
        /// Exchange rate for the current user's currency
        public var fxRate: Double { __data["fxRate"] }
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
        /// Total backers for the project
        public var backersCount: Int { __data["backersCount"] }
        /// Comment count - defaults to root level comments only
        public var commentsCount: Int { __data["commentsCount"] }
        /// The project's currency code.
        public var currency: GraphQLEnum<GraphAPI.CurrencyCode> { __data["currency"] }
        /// Currency code for the current user's currency
        public var fxRateCurrency: GraphQLEnum<GraphAPI.CurrencyCode> { __data["fxRateCurrency"] }
        /// The minimum amount to raise for the project to be successful.
        public var goal: Goal? { __data["goal"] }
        /// How much money is pledged to the project.
        public var pledged: Pledged { __data["pledged"] }
        /// Project updates.
        public var posts: Posts { __data["posts"] }
        /// Exchange rate to US Dollars (USD), null for draft projects.
        public var usdExchangeRate: Double? { __data["usdExchangeRate"] }
        /// Whether or not this is a Project of the Day.
        public var isProjectOfTheDay: Bool? { __data["isProjectOfTheDay"] }
        /// When is the project scheduled to end?
        public var deadlineAt: GraphAPI.DateTime? { __data["deadlineAt"] }
        /// The date at which pledge collections will end
        public var finalCollectionDate: GraphAPI.ISO8601DateTime? { __data["finalCollectionDate"] }
        /// When the project launched
        public var launchedAt: GraphAPI.DateTime? { __data["launchedAt"] }
        /// The last time a project's state changed, time since epoch
        public var stateChangedAt: GraphAPI.DateTime { __data["stateChangedAt"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var projectFragment: ProjectFragment { _toFragment() }
          public var extendedProjectPropertiesFragment: ExtendedProjectPropertiesFragment { _toFragment() }
          public var noRewardRewardFragment: NoRewardRewardFragment { _toFragment() }
          public var pledgeOverTimeFragment: PledgeOverTimeFragment { _toFragment() }
          public var projectStatsFragment: ProjectStatsFragment { _toFragment() }
          public var projectDatesFragment: ProjectDatesFragment { _toFragment() }
        }

        public init(
          availableCardTypes: [GraphQLEnum<GraphAPI.CreditCardTypes>],
          category: Category? = nil,
          canComment: Bool,
          country: Country,
          creator: Creator? = nil,
          description: String,
          image: Image? = nil,
          isProjectWeLove: Bool,
          isWatched: Bool,
          isLaunched: Bool,
          isInPostCampaignPledgingPhase: Bool,
          lastWave: LastWave? = nil,
          location: Location? = nil,
          maxPledge: Int,
          minPledge: Int,
          name: String,
          pid: Int,
          pledgeManager: PledgeManager? = nil,
          postCampaignPledgingEnabled: Bool,
          prelaunchActivated: Bool,
          redemptionPageUrl: String,
          sendMetaCapiEvents: Bool,
          slug: String,
          state: GraphQLEnum<GraphAPI.ProjectState>,
          tags: [Tag?],
          url: String,
          video: Video? = nil,
          watchesCount: Int? = nil,
          aiDisclosure: AiDisclosure? = nil,
          environmentalCommitments: [EnvironmentalCommitment?]? = nil,
          faqs: Faqs? = nil,
          projectNotice: String? = nil,
          risks: String,
          story: GraphAPI.HTML,
          fxRate: Double,
          isPledgeOverTimeAllowed: Bool,
          pledgeOverTimeCollectionPlanChargeExplanation: String? = nil,
          pledgeOverTimeCollectionPlanChargedAsNPayments: String? = nil,
          pledgeOverTimeCollectionPlanShortPitch: String? = nil,
          pledgeOverTimeMinimumExplanation: String? = nil,
          backersCount: Int,
          commentsCount: Int,
          currency: GraphQLEnum<GraphAPI.CurrencyCode>,
          fxRateCurrency: GraphQLEnum<GraphAPI.CurrencyCode>,
          goal: Goal? = nil,
          pledged: Pledged,
          posts: Posts,
          usdExchangeRate: Double? = nil,
          isProjectOfTheDay: Bool? = nil,
          deadlineAt: GraphAPI.DateTime? = nil,
          finalCollectionDate: GraphAPI.ISO8601DateTime? = nil,
          launchedAt: GraphAPI.DateTime? = nil,
          stateChangedAt: GraphAPI.DateTime
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Project.typename,
              "availableCardTypes": availableCardTypes,
              "category": category._fieldData,
              "canComment": canComment,
              "country": country._fieldData,
              "creator": creator._fieldData,
              "description": description,
              "image": image._fieldData,
              "isProjectWeLove": isProjectWeLove,
              "isWatched": isWatched,
              "isLaunched": isLaunched,
              "isInPostCampaignPledgingPhase": isInPostCampaignPledgingPhase,
              "lastWave": lastWave._fieldData,
              "location": location._fieldData,
              "maxPledge": maxPledge,
              "minPledge": minPledge,
              "name": name,
              "pid": pid,
              "pledgeManager": pledgeManager._fieldData,
              "postCampaignPledgingEnabled": postCampaignPledgingEnabled,
              "prelaunchActivated": prelaunchActivated,
              "redemptionPageUrl": redemptionPageUrl,
              "sendMetaCapiEvents": sendMetaCapiEvents,
              "slug": slug,
              "state": state,
              "tags": tags._fieldData,
              "url": url,
              "video": video._fieldData,
              "watchesCount": watchesCount,
              "aiDisclosure": aiDisclosure._fieldData,
              "environmentalCommitments": environmentalCommitments._fieldData,
              "faqs": faqs._fieldData,
              "projectNotice": projectNotice,
              "risks": risks,
              "story": story,
              "fxRate": fxRate,
              "isPledgeOverTimeAllowed": isPledgeOverTimeAllowed,
              "pledgeOverTimeCollectionPlanChargeExplanation": pledgeOverTimeCollectionPlanChargeExplanation,
              "pledgeOverTimeCollectionPlanChargedAsNPayments": pledgeOverTimeCollectionPlanChargedAsNPayments,
              "pledgeOverTimeCollectionPlanShortPitch": pledgeOverTimeCollectionPlanShortPitch,
              "pledgeOverTimeMinimumExplanation": pledgeOverTimeMinimumExplanation,
              "backersCount": backersCount,
              "commentsCount": commentsCount,
              "currency": currency,
              "fxRateCurrency": fxRateCurrency,
              "goal": goal._fieldData,
              "pledged": pledged._fieldData,
              "posts": posts._fieldData,
              "usdExchangeRate": usdExchangeRate,
              "isProjectOfTheDay": isProjectOfTheDay,
              "deadlineAt": deadlineAt,
              "finalCollectionDate": finalCollectionDate,
              "launchedAt": launchedAt,
              "stateChangedAt": stateChangedAt,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchBackingQuery.Data.Backing.Project.self),
              ObjectIdentifier(ProjectFragment.self),
              ObjectIdentifier(ExtendedProjectPropertiesFragment.self),
              ObjectIdentifier(NoRewardRewardFragment.self),
              ObjectIdentifier(PledgeOverTimeFragment.self),
              ObjectIdentifier(ProjectStatsFragment.self),
              ObjectIdentifier(ProjectDatesFragment.self),
              ObjectIdentifier(BackingFragment.Project.self)
            ]
          ))
        }

        /// Backing.Project.Category
        ///
        /// Parent Type: `Category`
        public struct Category: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Category }

          public var id: GraphAPI.ID { __data["id"] }
          /// Category name.
          public var name: String { __data["name"] }
          /// Category name in English for analytics use.
          public var analyticsName: String { __data["analyticsName"] }
          /// Category parent
          public var parentCategory: ParentCategory? { __data["parentCategory"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var categoryFragment: CategoryFragment { _toFragment() }
          }

          public init(
            id: GraphAPI.ID,
            name: String,
            analyticsName: String,
            parentCategory: ParentCategory? = nil
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.Category.typename,
                "id": id,
                "name": name,
                "analyticsName": analyticsName,
                "parentCategory": parentCategory._fieldData,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Project.Category.self),
                ObjectIdentifier(ProjectFragment.Category.self),
                ObjectIdentifier(CategoryFragment.self)
              ]
            ))
          }

          public typealias ParentCategory = CategoryFragment.ParentCategory
        }

        /// Backing.Project.Country
        ///
        /// Parent Type: `Country`
        public struct Country: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Country }

          /// ISO ALPHA-2 code.
          public var code: GraphQLEnum<GraphAPI.CountryCode> { __data["code"] }
          /// Country name.
          public var name: String { __data["name"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var countryFragment: CountryFragment { _toFragment() }
          }

          public init(
            code: GraphQLEnum<GraphAPI.CountryCode>,
            name: String
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.Country.typename,
                "code": code,
                "name": name,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Project.Country.self),
                ObjectIdentifier(ProjectFragment.Country.self),
                ObjectIdentifier(CountryFragment.self),
                ObjectIdentifier(BackingFragment.Project.Country.self)
              ]
            ))
          }
        }

        /// Backing.Project.Creator
        ///
        /// Parent Type: `User`
        public struct Creator: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }

          public var id: GraphAPI.ID { __data["id"] }
          /// The user's avatar.
          public var imageUrl: String { __data["imageUrl"] }
          /// Is user blocked by current user
          public var isBlocked: Bool? { __data["isBlocked"] }
          /// Whether or not you are following the user.
          public var isFollowing: Bool { __data["isFollowing"] }
          /// Where the user is based.
          public var location: Location? { __data["location"] }
          /// The user's provided name.
          public var name: String { __data["name"] }
          /// Is the user's profile public
          public var showPublicProfile: Bool? { __data["showPublicProfile"] }
          /// A user's uid
          public var uid: String { __data["uid"] }
          /// Number of backings for this user.
          public var backingsCount: Int { __data["backingsCount"] }
          /// Projects a user has created.
          public var createdProjects: CreatedProjects? { __data["createdProjects"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var publicUserFragment: PublicUserFragment { _toFragment() }
          }

          public init(
            id: GraphAPI.ID,
            imageUrl: String,
            isBlocked: Bool? = nil,
            isFollowing: Bool,
            location: Location? = nil,
            name: String,
            showPublicProfile: Bool? = nil,
            uid: String,
            backingsCount: Int,
            createdProjects: CreatedProjects? = nil
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.User.typename,
                "id": id,
                "imageUrl": imageUrl,
                "isBlocked": isBlocked,
                "isFollowing": isFollowing,
                "location": location._fieldData,
                "name": name,
                "showPublicProfile": showPublicProfile,
                "uid": uid,
                "backingsCount": backingsCount,
                "createdProjects": createdProjects._fieldData,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Project.Creator.self),
                ObjectIdentifier(ProjectFragment.Creator.self),
                ObjectIdentifier(PublicUserFragment.self)
              ]
            ))
          }

          /// Backing.Project.Creator.Location
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
                  ObjectIdentifier(FetchBackingQuery.Data.Backing.Project.Creator.Location.self),
                  ObjectIdentifier(PublicUserFragment.Location.self),
                  ObjectIdentifier(LocationFragment.self)
                ]
              ))
            }
          }

          public typealias CreatedProjects = PublicUserFragment.CreatedProjects
        }

        public typealias Image = ProjectFragment.Image

        /// Backing.Project.LastWave
        ///
        /// Parent Type: `CheckoutWave`
        public struct LastWave: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CheckoutWave }

          public var id: GraphAPI.ID { __data["id"] }
          /// Whether the wave is currently active
          public var active: Bool { __data["active"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var lastWaveFragment: LastWaveFragment { _toFragment() }
          }

          public init(
            id: GraphAPI.ID,
            active: Bool
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.CheckoutWave.typename,
                "id": id,
                "active": active,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Project.LastWave.self),
                ObjectIdentifier(ProjectFragment.LastWave.self),
                ObjectIdentifier(LastWaveFragment.self)
              ]
            ))
          }
        }

        /// Backing.Project.Location
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
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Project.Location.self),
                ObjectIdentifier(ProjectFragment.Location.self),
                ObjectIdentifier(LocationFragment.self)
              ]
            ))
          }
        }

        /// Backing.Project.PledgeManager
        ///
        /// Parent Type: `PledgeManager`
        public struct PledgeManager: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PledgeManager }

          public var id: GraphAPI.ID { __data["id"] }
          /// Whether the pledge manager accepts new backers or not
          public var acceptsNewBackers: Bool { __data["acceptsNewBackers"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var pledgeManagerFragment: PledgeManagerFragment { _toFragment() }
          }

          public init(
            id: GraphAPI.ID,
            acceptsNewBackers: Bool
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.PledgeManager.typename,
                "id": id,
                "acceptsNewBackers": acceptsNewBackers,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Project.PledgeManager.self),
                ObjectIdentifier(ProjectFragment.PledgeManager.self),
                ObjectIdentifier(PledgeManagerFragment.self)
              ]
            ))
          }
        }

        public typealias Tag = ProjectFragment.Tag

        /// Backing.Project.Video
        ///
        /// Parent Type: `Video`
        public struct Video: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Video }

          public var id: GraphAPI.ID { __data["id"] }
          /// A video's sources (hls, high, base)
          public var videoSources: VideoSources? { __data["videoSources"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var projectVideoFragment: ProjectVideoFragment { _toFragment() }
          }

          public init(
            id: GraphAPI.ID,
            videoSources: VideoSources? = nil
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.Video.typename,
                "id": id,
                "videoSources": videoSources._fieldData,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Project.Video.self),
                ObjectIdentifier(ProjectFragment.Video.self),
                ObjectIdentifier(ProjectVideoFragment.self)
              ]
            ))
          }

          public typealias VideoSources = ProjectVideoFragment.VideoSources
        }

        public typealias AiDisclosure = ExtendedProjectPropertiesFragment.AiDisclosure

        public typealias EnvironmentalCommitment = ExtendedProjectPropertiesFragment.EnvironmentalCommitment

        public typealias Faqs = ExtendedProjectPropertiesFragment.Faqs

        /// Backing.Project.Goal
        ///
        /// Parent Type: `Money`
        public struct Goal: GraphAPI.SelectionSet {
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
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Project.Goal.self),
                ObjectIdentifier(ProjectStatsFragment.Goal.self),
                ObjectIdentifier(MoneyFragment.self)
              ]
            ))
          }
        }

        /// Backing.Project.Pledged
        ///
        /// Parent Type: `Money`
        public struct Pledged: GraphAPI.SelectionSet {
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
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Project.Pledged.self),
                ObjectIdentifier(ProjectStatsFragment.Pledged.self),
                ObjectIdentifier(MoneyFragment.self)
              ]
            ))
          }
        }

        public typealias Posts = ProjectStatsFragment.Posts
      }

      /// Backing.PaymentIncrement
      ///
      /// Parent Type: `PaymentIncrement`
      public struct PaymentIncrement: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PaymentIncrement }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(PaymentIncrementFragment.self),
        ] }

        /// The payment increment amount represented in various formats
        public var amount: Amount { __data["amount"] }
        public var scheduledCollection: GraphAPI.ISO8601DateTime { __data["scheduledCollection"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var paymentIncrementFragment: PaymentIncrementFragment { _toFragment() }
        }

        public init(
          amount: Amount,
          scheduledCollection: GraphAPI.ISO8601DateTime
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.PaymentIncrement.typename,
              "amount": amount._fieldData,
              "scheduledCollection": scheduledCollection,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchBackingQuery.Data.Backing.PaymentIncrement.self),
              ObjectIdentifier(PaymentIncrementFragment.self)
            ]
          ))
        }

        public typealias Amount = PaymentIncrementFragment.Amount
      }

      /// Backing.Amount
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
              ObjectIdentifier(FetchBackingQuery.Data.Backing.Amount.self),
              ObjectIdentifier(BackingFragment.Amount.self),
              ObjectIdentifier(MoneyFragment.self)
            ]
          ))
        }
      }

      /// Backing.Backer
      ///
      /// Parent Type: `User`
      public struct Backer: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }

        public var id: GraphAPI.ID { __data["id"] }
        /// The user's avatar.
        public var imageUrl: String { __data["imageUrl"] }
        /// Is user blocked by current user
        public var isBlocked: Bool? { __data["isBlocked"] }
        /// Whether or not you are following the user.
        public var isFollowing: Bool { __data["isFollowing"] }
        /// Where the user is based.
        public var location: Location? { __data["location"] }
        /// The user's provided name.
        public var name: String { __data["name"] }
        /// Is the user's profile public
        public var showPublicProfile: Bool? { __data["showPublicProfile"] }
        /// A user's uid
        public var uid: String { __data["uid"] }
        /// Number of backings for this user.
        public var backingsCount: Int { __data["backingsCount"] }
        /// Projects a user has created.
        public var createdProjects: CreatedProjects? { __data["createdProjects"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var publicUserFragment: PublicUserFragment { _toFragment() }
        }

        public init(
          id: GraphAPI.ID,
          imageUrl: String,
          isBlocked: Bool? = nil,
          isFollowing: Bool,
          location: Location? = nil,
          name: String,
          showPublicProfile: Bool? = nil,
          uid: String,
          backingsCount: Int,
          createdProjects: CreatedProjects? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.User.typename,
              "id": id,
              "imageUrl": imageUrl,
              "isBlocked": isBlocked,
              "isFollowing": isFollowing,
              "location": location._fieldData,
              "name": name,
              "showPublicProfile": showPublicProfile,
              "uid": uid,
              "backingsCount": backingsCount,
              "createdProjects": createdProjects._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchBackingQuery.Data.Backing.Backer.self),
              ObjectIdentifier(BackingFragment.Backer.self),
              ObjectIdentifier(PublicUserFragment.self)
            ]
          ))
        }

        /// Backing.Backer.Location
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
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Backer.Location.self),
                ObjectIdentifier(PublicUserFragment.Location.self),
                ObjectIdentifier(LocationFragment.self)
              ]
            ))
          }
        }

        public typealias CreatedProjects = PublicUserFragment.CreatedProjects
      }

      /// Backing.BonusAmount
      ///
      /// Parent Type: `Money`
      public struct BonusAmount: GraphAPI.SelectionSet {
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
              ObjectIdentifier(FetchBackingQuery.Data.Backing.BonusAmount.self),
              ObjectIdentifier(BackingFragment.BonusAmount.self),
              ObjectIdentifier(MoneyFragment.self)
            ]
          ))
        }
      }

      public typealias PaymentSource = BackingFragment.PaymentSource

      /// Backing.Location
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
              ObjectIdentifier(FetchBackingQuery.Data.Backing.Location.self),
              ObjectIdentifier(BackingFragment.Location.self),
              ObjectIdentifier(LocationFragment.self)
            ]
          ))
        }
      }

      /// Backing.Order
      ///
      /// Parent Type: `Order`
      public struct Order: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Order }

        public var id: GraphAPI.ID { __data["id"] }
        /// The state of checkout (taking into account order and cart status)
        public var checkoutState: GraphQLEnum<GraphAPI.CheckoutStateEnum> { __data["checkoutState"] }
        /// The currency of the order
        public var currency: GraphQLEnum<GraphAPI.CurrencyCode> { __data["currency"] }
        /// The total cost for the order including taxes and shipping
        public var total: Int? { __data["total"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var orderFragment: OrderFragment { _toFragment() }
        }

        public init(
          id: GraphAPI.ID,
          checkoutState: GraphQLEnum<GraphAPI.CheckoutStateEnum>,
          currency: GraphQLEnum<GraphAPI.CurrencyCode>,
          total: Int? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Order.typename,
              "id": id,
              "checkoutState": checkoutState,
              "currency": currency,
              "total": total,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchBackingQuery.Data.Backing.Order.self),
              ObjectIdentifier(BackingFragment.Order.self),
              ObjectIdentifier(OrderFragment.self)
            ]
          ))
        }
      }

      /// Backing.Reward
      ///
      /// Parent Type: `Reward`
      public struct Reward: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Reward }

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
        /// When the reward is scheduled to start
        public var startsAt: GraphAPI.DateTime? { __data["startsAt"] }
        /// The reward image.
        public var image: Image? { __data["image"] }
        /// Data related to who can view/access this reward
        public var audienceData: AudienceData { __data["audienceData"] }
        /// Simple shipping rules expanded as a faster alternative to shippingRulesExpanded since connection type is slow
        public var simpleShippingRulesExpanded: [SimpleShippingRulesExpanded?] { __data["simpleShippingRulesExpanded"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var rewardFragment: RewardFragment { _toFragment() }
          public var simpleShippingRulesExpandedFragment: SimpleShippingRulesExpandedFragment { _toFragment() }
        }

        public init(
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
          startsAt: GraphAPI.DateTime? = nil,
          image: Image? = nil,
          audienceData: AudienceData,
          simpleShippingRulesExpanded: [SimpleShippingRulesExpanded?]
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Reward.typename,
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
              "startsAt": startsAt,
              "image": image._fieldData,
              "audienceData": audienceData._fieldData,
              "simpleShippingRulesExpanded": simpleShippingRulesExpanded._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchBackingQuery.Data.Backing.Reward.self),
              ObjectIdentifier(BackingFragment.Reward.self),
              ObjectIdentifier(RewardFragment.self),
              ObjectIdentifier(SimpleShippingRulesExpandedFragment.self)
            ]
          ))
        }

        /// Backing.Reward.Amount
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
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Reward.Amount.self),
                ObjectIdentifier(RewardFragment.Amount.self),
                ObjectIdentifier(MoneyFragment.self)
              ]
            ))
          }
        }

        /// Backing.Reward.ConvertedAmount
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
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Reward.ConvertedAmount.self),
                ObjectIdentifier(RewardFragment.ConvertedAmount.self),
                ObjectIdentifier(MoneyFragment.self)
              ]
            ))
          }
        }

        public typealias AllowedAddons = RewardFragment.AllowedAddons

        public typealias Items = RewardFragment.Items

        /// Backing.Reward.LocalReceiptLocation
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
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Reward.LocalReceiptLocation.self),
                ObjectIdentifier(RewardFragment.LocalReceiptLocation.self),
                ObjectIdentifier(LocationFragment.self)
              ]
            ))
          }
        }

        /// Backing.Reward.PledgeAmount
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
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Reward.PledgeAmount.self),
                ObjectIdentifier(RewardFragment.PledgeAmount.self),
                ObjectIdentifier(MoneyFragment.self)
              ]
            ))
          }
        }

        /// Backing.Reward.LatePledgeAmount
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
                ObjectIdentifier(FetchBackingQuery.Data.Backing.Reward.LatePledgeAmount.self),
                ObjectIdentifier(RewardFragment.LatePledgeAmount.self),
                ObjectIdentifier(MoneyFragment.self)
              ]
            ))
          }
        }

        public typealias Project = RewardFragment.Project

        public typealias Image = RewardFragment.Image

        public typealias AudienceData = RewardFragment.AudienceData

        public typealias SimpleShippingRulesExpanded = SimpleShippingRulesExpandedFragment.SimpleShippingRulesExpanded
      }

      /// Backing.RewardsAmount
      ///
      /// Parent Type: `Money`
      public struct RewardsAmount: GraphAPI.SelectionSet {
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
              ObjectIdentifier(FetchBackingQuery.Data.Backing.RewardsAmount.self),
              ObjectIdentifier(BackingFragment.RewardsAmount.self),
              ObjectIdentifier(MoneyFragment.self)
            ]
          ))
        }
      }

      /// Backing.ShippingAmount
      ///
      /// Parent Type: `Money`
      public struct ShippingAmount: GraphAPI.SelectionSet {
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
              ObjectIdentifier(FetchBackingQuery.Data.Backing.ShippingAmount.self),
              ObjectIdentifier(BackingFragment.ShippingAmount.self),
              ObjectIdentifier(MoneyFragment.self)
            ]
          ))
        }
      }
    }
  }
}
