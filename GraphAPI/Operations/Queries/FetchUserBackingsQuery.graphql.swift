// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  class FetchUserBackingsQuery: GraphQLQuery {
    public static let operationName: String = "FetchUserBackings"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query FetchUserBackings($status: BackingState!, $withStoredCards: Boolean!, $includeShippingRules: Boolean!, $includeLocalPickup: Boolean!) { me { __typename backings(status: $status) { __typename nodes { __typename addOns { __typename nodes { __typename ...RewardFragment } } ...BackingFragment errorReason } totalCount } id imageUrl: imageUrl(blur: false, width: 1024) name uid } }"#,
        fragments: [BackingFragment.self, CategoryFragment.self, CountryFragment.self, LocationFragment.self, MoneyFragment.self, OrderFragment.self, PaymentIncrementFragment.self, PaymentSourceFragment.self, ProjectFragment.self, RewardFragment.self, ShippingRuleFragment.self, UserFragment.self, UserStoredCardsFragment.self]
      ))

    public var status: GraphQLEnum<BackingState>
    public var withStoredCards: Bool
    public var includeShippingRules: Bool
    public var includeLocalPickup: Bool

    public init(
      status: GraphQLEnum<BackingState>,
      withStoredCards: Bool,
      includeShippingRules: Bool,
      includeLocalPickup: Bool
    ) {
      self.status = status
      self.withStoredCards = withStoredCards
      self.includeShippingRules = includeShippingRules
      self.includeLocalPickup = includeLocalPickup
    }

    public var __variables: Variables? { [
      "status": status,
      "withStoredCards": withStoredCards,
      "includeShippingRules": includeShippingRules,
      "includeLocalPickup": includeLocalPickup
    ] }

    public struct Data: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("me", Me?.self),
      ] }

      /// You.
      public var me: Me? { __data["me"] }

      /// Me
      ///
      /// Parent Type: `User`
      public struct Me: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("backings", Backings?.self, arguments: ["status": .variable("status")]),
          .field("id", GraphAPI.ID.self),
          .field("imageUrl", alias: "imageUrl", String.self, arguments: [
            "blur": false,
            "width": 1024
          ]),
          .field("name", String.self),
          .field("uid", String.self),
        ] }

        /// A user's backings.
        public var backings: Backings? { __data["backings"] }
        public var id: GraphAPI.ID { __data["id"] }
        /// The user's avatar.
        public var imageUrl: String { __data["imageUrl"] }
        /// The user's provided name.
        public var name: String { __data["name"] }
        /// A user's uid
        public var uid: String { __data["uid"] }

        /// Me.Backings
        ///
        /// Parent Type: `UserBackingsConnection`
        public struct Backings: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserBackingsConnection }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?]?.self),
            .field("totalCount", Int.self),
          ] }

          /// A list of nodes.
          public var nodes: [Node?]? { __data["nodes"] }
          @available(*, deprecated, message: "Please use backingsCount instead.")
          public var totalCount: Int { __data["totalCount"] }

          /// Me.Backings.Node
          ///
          /// Parent Type: `Backing`
          public struct Node: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Backing }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("addOns", AddOns?.self),
              .field("errorReason", String?.self),
              .fragment(BackingFragment.self),
            ] }

            /// The add-ons that the backer selected
            public var addOns: AddOns? { __data["addOns"] }
            /// The reason for an errored backing
            public var errorReason: String? { __data["errorReason"] }
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
            /// Scheduled incremental payments
            public var paymentIncrements: [PaymentIncrement]? { __data["paymentIncrements"] }
            /// When the backing was created
            public var pledgedOn: GraphAPI.DateTime? { __data["pledgedOn"] }
            /// The project
            public var project: Project? { __data["project"] }
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

            /// Me.Backings.Node.AddOns
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

              /// Me.Backings.Node.AddOns.Node
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
                /// Amount for claiming this reward, in the current user's chosen
                ///                                                      currency
                public var convertedAmount: ConvertedAmount { __data["convertedAmount"] }
                /// Add-ons which can be combined with this reward.
                /// Uses creator preferences and shipping rules to determine allow-ability.
                /// Inclusion in this list does not necessarily indicate that the add-on is available for backing.
                ///
                public var allowedAddons: AllowedAddons { __data["allowedAddons"] }
                /// A reward description.
                public var description: String { __data["description"] }
                /// A reward's title plus the amount, or a default title (the reward amount) if it doesn't
                ///                                  have a title.
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
                /// Where the reward can be locally received if local receipt
                ///                                                              is selected as the shipping preference
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
                /// Shipping rules defined by the creator for
                ///                                                                            this reward
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

                /// Me.Backings.Node.AddOns.Node.Amount
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
                }

                /// Me.Backings.Node.AddOns.Node.ConvertedAmount
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
                }

                public typealias AllowedAddons = RewardFragment.AllowedAddons

                public typealias Items = RewardFragment.Items

                /// Me.Backings.Node.AddOns.Node.LocalReceiptLocation
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
                }

                /// Me.Backings.Node.AddOns.Node.PledgeAmount
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
                }

                /// Me.Backings.Node.AddOns.Node.LatePledgeAmount
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
                }

                public typealias Project = RewardFragment.Project

                /// Me.Backings.Node.AddOns.Node.ShippingRule
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

                  /// Me.Backings.Node.AddOns.Node.ShippingRule.Cost
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
                  }

                  /// Me.Backings.Node.AddOns.Node.ShippingRule.Location
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
                  }

                  public typealias EstimatedMin = ShippingRuleFragment.EstimatedMin

                  public typealias EstimatedMax = ShippingRuleFragment.EstimatedMax
                }

                public typealias Image = RewardFragment.Image

                public typealias AudienceData = RewardFragment.AudienceData
              }
            }

            /// Me.Backings.Node.Amount
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
            }

            /// Me.Backings.Node.Backer
            ///
            /// Parent Type: `User`
            public struct Backer: GraphAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }

              /// A user's backings.
              public var backings: Backings? { __data["backings"] }
              /// Number of backings for this user.
              public var backingsCount: Int { __data["backingsCount"] }
              /// The user's chosen currency
              public var chosenCurrency: String? { __data["chosenCurrency"] }
              /// Projects a user has created.
              public var createdProjects: CreatedProjects? { __data["createdProjects"] }
              /// A user's email address.
              public var email: String? { __data["email"] }
              /// Whether or not the user has a password.
              public var hasPassword: Bool? { __data["hasPassword"] }
              /// Whether or not a user has unread messages.
              public var hasUnreadMessages: Bool? { __data["hasUnreadMessages"] }
              /// Whether or not a user has unseen activity.
              public var hasUnseenActivity: Bool? { __data["hasUnseenActivity"] }
              public var id: GraphAPI.ID { __data["id"] }
              /// The user's avatar.
              public var imageUrl: String { __data["imageUrl"] }
              /// Whether or not the user has authenticated with Apple.
              public var isAppleConnected: Bool? { __data["isAppleConnected"] }
              /// Is user blocked by current user
              public var isBlocked: Bool? { __data["isBlocked"] }
              /// Whether a user is a creator of any project
              public var isCreator: Bool? { __data["isCreator"] }
              /// Whether a user's email address is deliverable
              public var isDeliverable: Bool? { __data["isDeliverable"] }
              /// Whether or not the user's email is verified.
              public var isEmailVerified: Bool? { __data["isEmailVerified"] }
              /// Whether or not the user is connected to Facebook.
              public var isFacebookConnected: Bool? { __data["isFacebookConnected"] }
              /// Whether or not you are a KSR admin.
              public var isKsrAdmin: Bool? { __data["isKsrAdmin"] }
              /// Whether or not you are following the user.
              public var isFollowing: Bool { __data["isFollowing"] }
              /// Whether or not the user is either Facebook connected or has follows/followings.
              public var isSocializing: Bool? { __data["isSocializing"] }
              /// Where the user is based.
              public var location: Location? { __data["location"] }
              /// The user's provided name.
              public var name: String { __data["name"] }
              /// Does the user to refresh their facebook token?
              public var needsFreshFacebookToken: Bool? { __data["needsFreshFacebookToken"] }
              /// Which newsleters are the users subscribed to
              public var newsletterSubscriptions: NewsletterSubscriptions? { __data["newsletterSubscriptions"] }
              /// All of a user's notifications
              public var notifications: [Notification]? { __data["notifications"] }
              /// Is the user opted out from receiving recommendations
              public var optedOutOfRecommendations: Bool? { __data["optedOutOfRecommendations"] }
              /// Is the user's profile public
              public var showPublicProfile: Bool? { __data["showPublicProfile"] }
              /// Projects a user has saved.
              public var savedProjects: SavedProjects? { __data["savedProjects"] }
              /// Stored Cards
              public var storedCards: StoredCards? { __data["storedCards"] }
              /// This user's survey responses
              public var surveyResponses: SurveyResponses? { __data["surveyResponses"] }
              /// A user's uid
              public var uid: String { __data["uid"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var userFragment: UserFragment { _toFragment() }
              }

              public typealias Backings = UserFragment.Backings

              public typealias CreatedProjects = UserFragment.CreatedProjects

              /// Me.Backings.Node.Backer.Location
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
              }

              public typealias NewsletterSubscriptions = UserFragment.NewsletterSubscriptions

              public typealias Notification = UserFragment.Notification

              public typealias SavedProjects = UserFragment.SavedProjects

              /// Me.Backings.Node.Backer.StoredCards
              ///
              /// Parent Type: `UserCreditCardTypeConnection`
              public struct StoredCards: GraphAPI.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserCreditCardTypeConnection }

                /// A list of nodes.
                public var nodes: [Node?]? { __data["nodes"] }
                public var totalCount: Int { __data["totalCount"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var userStoredCardsFragment: UserStoredCardsFragment { _toFragment() }
                }

                public typealias Node = UserStoredCardsFragment.Node
              }

              public typealias SurveyResponses = UserFragment.SurveyResponses
            }

            /// Me.Backings.Node.BonusAmount
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
            }

            public typealias PaymentSource = BackingFragment.PaymentSource

            /// Me.Backings.Node.Location
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
            }

            /// Me.Backings.Node.Order
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
            }

            /// Me.Backings.Node.PaymentIncrement
            ///
            /// Parent Type: `PaymentIncrement`
            public struct PaymentIncrement: GraphAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PaymentIncrement }

              /// The payment increment amount represented in various formats
              public var amount: Amount { __data["amount"] }
              public var scheduledCollection: GraphAPI.ISO8601DateTime { __data["scheduledCollection"] }
              public var state: GraphQLEnum<GraphAPI.PaymentIncrementState> { __data["state"] }
              public var stateReason: GraphQLEnum<GraphAPI.PaymentIncrementStateReason>? { __data["stateReason"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var paymentIncrementFragment: PaymentIncrementFragment { _toFragment() }
              }

              public typealias Amount = PaymentIncrementFragment.Amount
            }

            /// Me.Backings.Node.Project
            ///
            /// Parent Type: `Project`
            public struct Project: GraphAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }

              /// Available card types.
              public var availableCardTypes: [GraphQLEnum<GraphAPI.CreditCardTypes>] { __data["availableCardTypes"] }
              /// Total backers for the project
              public var backersCount: Int { __data["backersCount"] }
              /// The project's category.
              public var category: Category? { __data["category"] }
              /// True if the current user can comment (considers restrictions)
              public var canComment: Bool { __data["canComment"] }
              /// Comment count - defaults to root level comments only
              public var commentsCount: Int { __data["commentsCount"] }
              /// The project's country
              public var country: Country { __data["country"] }
              /// The project's creator.
              public var creator: Creator? { __data["creator"] }
              /// The project's currency code.
              public var currency: GraphQLEnum<GraphAPI.CurrencyCode> { __data["currency"] }
              /// When is the project scheduled to end?
              public var deadlineAt: GraphAPI.DateTime? { __data["deadlineAt"] }
              /// A short description of the project.
              public var description: String { __data["description"] }
              /// The environmental commitments of the project.
              public var environmentalCommitments: [EnvironmentalCommitment?]? { __data["environmentalCommitments"] }
              public var aiDisclosure: AiDisclosure? { __data["aiDisclosure"] }
              /// List of FAQs of a project
              public var faqs: Faqs? { __data["faqs"] }
              /// The date at which pledge collections will end
              public var finalCollectionDate: GraphAPI.ISO8601DateTime? { __data["finalCollectionDate"] }
              /// Exchange rate for the current user's currency
              public var fxRate: Double { __data["fxRate"] }
              /// The minimum amount to raise for the project to be successful.
              public var goal: Goal? { __data["goal"] }
              /// The project's primary image.
              public var image: Image? { __data["image"] }
              /// Whether a project is enrolled in plot
              public var isPledgeOverTimeAllowed: Bool { __data["isPledgeOverTimeAllowed"] }
              /// Whether or not this is a Kickstarter-featured project.
              public var isProjectWeLove: Bool { __data["isProjectWeLove"] }
              /// Whether or not this is a Project of the Day.
              public var isProjectOfTheDay: Bool? { __data["isProjectOfTheDay"] }
              /// Is the current user watching this project?
              public var isWatched: Bool { __data["isWatched"] }
              /// The project has launched
              public var isLaunched: Bool { __data["isLaunched"] }
              /// Is this project currently accepting post-campaign pledges?
              public var isInPostCampaignPledgingPhase: Bool { __data["isInPostCampaignPledgingPhase"] }
              /// When the project launched
              public var launchedAt: GraphAPI.DateTime? { __data["launchedAt"] }
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
              /// Backer-facing summary of when the incremental charges will occur
              public var pledgeOverTimeCollectionPlanChargeExplanation: String? { __data["pledgeOverTimeCollectionPlanChargeExplanation"] }
              /// Quick summary of the amount of increments pledges will be spread over
              public var pledgeOverTimeCollectionPlanChargedAsNPayments: String? { __data["pledgeOverTimeCollectionPlanChargedAsNPayments"] }
              /// Backer-facing short summary of this project's number of payment increments to split over
              public var pledgeOverTimeCollectionPlanShortPitch: String? { __data["pledgeOverTimeCollectionPlanShortPitch"] }
              /// The minimum pledge amount to be eligible for PLOT, localized to the project currency and backer language
              public var pledgeOverTimeMinimumExplanation: String? { __data["pledgeOverTimeMinimumExplanation"] }
              /// How much money is pledged to the project.
              public var pledged: Pledged { __data["pledged"] }
              /// Is this project configured for post-campaign pledges?
              public var postCampaignPledgingEnabled: Bool { __data["postCampaignPledgingEnabled"] }
              /// Project updates.
              public var posts: Posts? { __data["posts"] }
              /// Whether a project has activated prelaunch.
              public var prelaunchActivated: Bool { __data["prelaunchActivated"] }
              /// The text of the currently applied project notice, empty if there is no notice
              public var projectNotice: String? { __data["projectNotice"] }
              /// Potential hurdles to project completion.
              public var risks: String { __data["risks"] }
              /// Is this project configured so that events should be triggered for Meta's Conversions API?
              public var sendMetaCapiEvents: Bool { __data["sendMetaCapiEvents"] }
              /// The project's unique URL identifier.
              public var slug: String { __data["slug"] }
              /// The project's current state.
              public var state: GraphQLEnum<GraphAPI.ProjectState> { __data["state"] }
              /// The last time a project's state changed, time since epoch
              public var stateChangedAt: GraphAPI.DateTime { __data["stateChangedAt"] }
              /// The story behind the project, parsed for presentation.
              public var story: GraphAPI.HTML { __data["story"] }
              /// Tags project has been tagged with
              public var tags: [Tag?] { __data["tags"] }
              /// A URL to the project's page.
              public var url: String { __data["url"] }
              /// Exchange rate to US Dollars (USD), null for draft projects.
              public var usdExchangeRate: Double? { __data["usdExchangeRate"] }
              /// A project video.
              public var video: Video? { __data["video"] }
              /// Number of watchers a project has.
              public var watchesCount: Int? { __data["watchesCount"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var projectFragment: ProjectFragment { _toFragment() }
              }

              /// Me.Backings.Node.Project.Category
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

                public typealias ParentCategory = CategoryFragment.ParentCategory
              }

              /// Me.Backings.Node.Project.Country
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
              }

              /// Me.Backings.Node.Project.Creator
              ///
              /// Parent Type: `User`
              public struct Creator: GraphAPI.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }

                /// A user's backings.
                public var backings: Backings? { __data["backings"] }
                /// Number of backings for this user.
                public var backingsCount: Int { __data["backingsCount"] }
                /// The user's chosen currency
                public var chosenCurrency: String? { __data["chosenCurrency"] }
                /// Projects a user has created.
                public var createdProjects: CreatedProjects? { __data["createdProjects"] }
                /// A user's email address.
                public var email: String? { __data["email"] }
                /// Whether or not the user has a password.
                public var hasPassword: Bool? { __data["hasPassword"] }
                /// Whether or not a user has unread messages.
                public var hasUnreadMessages: Bool? { __data["hasUnreadMessages"] }
                /// Whether or not a user has unseen activity.
                public var hasUnseenActivity: Bool? { __data["hasUnseenActivity"] }
                public var id: GraphAPI.ID { __data["id"] }
                /// The user's avatar.
                public var imageUrl: String { __data["imageUrl"] }
                /// Whether or not the user has authenticated with Apple.
                public var isAppleConnected: Bool? { __data["isAppleConnected"] }
                /// Is user blocked by current user
                public var isBlocked: Bool? { __data["isBlocked"] }
                /// Whether a user is a creator of any project
                public var isCreator: Bool? { __data["isCreator"] }
                /// Whether a user's email address is deliverable
                public var isDeliverable: Bool? { __data["isDeliverable"] }
                /// Whether or not the user's email is verified.
                public var isEmailVerified: Bool? { __data["isEmailVerified"] }
                /// Whether or not the user is connected to Facebook.
                public var isFacebookConnected: Bool? { __data["isFacebookConnected"] }
                /// Whether or not you are a KSR admin.
                public var isKsrAdmin: Bool? { __data["isKsrAdmin"] }
                /// Whether or not you are following the user.
                public var isFollowing: Bool { __data["isFollowing"] }
                /// Whether or not the user is either Facebook connected or has follows/followings.
                public var isSocializing: Bool? { __data["isSocializing"] }
                /// Where the user is based.
                public var location: Location? { __data["location"] }
                /// The user's provided name.
                public var name: String { __data["name"] }
                /// Does the user to refresh their facebook token?
                public var needsFreshFacebookToken: Bool? { __data["needsFreshFacebookToken"] }
                /// Which newsleters are the users subscribed to
                public var newsletterSubscriptions: NewsletterSubscriptions? { __data["newsletterSubscriptions"] }
                /// All of a user's notifications
                public var notifications: [Notification]? { __data["notifications"] }
                /// Is the user opted out from receiving recommendations
                public var optedOutOfRecommendations: Bool? { __data["optedOutOfRecommendations"] }
                /// Is the user's profile public
                public var showPublicProfile: Bool? { __data["showPublicProfile"] }
                /// Projects a user has saved.
                public var savedProjects: SavedProjects? { __data["savedProjects"] }
                /// Stored Cards
                public var storedCards: StoredCards? { __data["storedCards"] }
                /// This user's survey responses
                public var surveyResponses: SurveyResponses? { __data["surveyResponses"] }
                /// A user's uid
                public var uid: String { __data["uid"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var userFragment: UserFragment { _toFragment() }
                }

                public typealias Backings = UserFragment.Backings

                public typealias CreatedProjects = UserFragment.CreatedProjects

                /// Me.Backings.Node.Project.Creator.Location
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
                }

                public typealias NewsletterSubscriptions = UserFragment.NewsletterSubscriptions

                public typealias Notification = UserFragment.Notification

                public typealias SavedProjects = UserFragment.SavedProjects

                /// Me.Backings.Node.Project.Creator.StoredCards
                ///
                /// Parent Type: `UserCreditCardTypeConnection`
                public struct StoredCards: GraphAPI.SelectionSet {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserCreditCardTypeConnection }

                  /// A list of nodes.
                  public var nodes: [Node?]? { __data["nodes"] }
                  public var totalCount: Int { __data["totalCount"] }

                  public struct Fragments: FragmentContainer {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public var userStoredCardsFragment: UserStoredCardsFragment { _toFragment() }
                  }

                  public typealias Node = UserStoredCardsFragment.Node
                }

                public typealias SurveyResponses = UserFragment.SurveyResponses
              }

              public typealias EnvironmentalCommitment = ProjectFragment.EnvironmentalCommitment

              public typealias AiDisclosure = ProjectFragment.AiDisclosure

              public typealias Faqs = ProjectFragment.Faqs

              /// Me.Backings.Node.Project.Goal
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
              }

              public typealias Image = ProjectFragment.Image

              /// Me.Backings.Node.Project.Location
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
              }

              /// Me.Backings.Node.Project.Pledged
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
              }

              public typealias Posts = ProjectFragment.Posts

              public typealias Tag = ProjectFragment.Tag

              public typealias Video = ProjectFragment.Video
            }

            /// Me.Backings.Node.Reward
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
              /// Amount for claiming this reward, in the current user's chosen
              ///                                                      currency
              public var convertedAmount: ConvertedAmount { __data["convertedAmount"] }
              /// Add-ons which can be combined with this reward.
              /// Uses creator preferences and shipping rules to determine allow-ability.
              /// Inclusion in this list does not necessarily indicate that the add-on is available for backing.
              ///
              public var allowedAddons: AllowedAddons { __data["allowedAddons"] }
              /// A reward description.
              public var description: String { __data["description"] }
              /// A reward's title plus the amount, or a default title (the reward amount) if it doesn't
              ///                                  have a title.
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
              /// Where the reward can be locally received if local receipt
              ///                                                              is selected as the shipping preference
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
              /// Shipping rules defined by the creator for
              ///                                                                            this reward
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

              /// Me.Backings.Node.Reward.Amount
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
              }

              /// Me.Backings.Node.Reward.ConvertedAmount
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
              }

              public typealias AllowedAddons = RewardFragment.AllowedAddons

              public typealias Items = RewardFragment.Items

              /// Me.Backings.Node.Reward.LocalReceiptLocation
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
              }

              /// Me.Backings.Node.Reward.PledgeAmount
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
              }

              /// Me.Backings.Node.Reward.LatePledgeAmount
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
              }

              public typealias Project = RewardFragment.Project

              /// Me.Backings.Node.Reward.ShippingRule
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

                /// Me.Backings.Node.Reward.ShippingRule.Cost
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
                }

                /// Me.Backings.Node.Reward.ShippingRule.Location
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
                }

                public typealias EstimatedMin = ShippingRuleFragment.EstimatedMin

                public typealias EstimatedMax = ShippingRuleFragment.EstimatedMax
              }

              public typealias Image = RewardFragment.Image

              public typealias AudienceData = RewardFragment.AudienceData
            }

            /// Me.Backings.Node.RewardsAmount
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
            }

            /// Me.Backings.Node.ShippingAmount
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
            }
          }
        }
      }
    }
  }

}