// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct BackingFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment BackingFragment on Backing { __typename amount { __typename ...MoneyFragment } backer { __typename ...UserFragment } backerCompleted bonusAmount { __typename ...MoneyFragment } cancelable paymentSource { __typename ...PaymentSourceFragment } id isLatePledge location { __typename ...LocationFragment } order { __typename ...OrderFragment } paymentIncrements { __typename ...PaymentIncrementFragment } pledgedOn project { __typename ...ProjectFragment } reward { __typename ...RewardFragment } rewardsAmount { __typename ...MoneyFragment } sequence shippingAmount { __typename ...MoneyFragment } status backingDetailsPageRoute(type: url, tab: survey_responses) }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Backing }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("amount", Amount.self),
    .field("backer", Backer?.self),
    .field("backerCompleted", Bool.self),
    .field("bonusAmount", BonusAmount.self),
    .field("cancelable", Bool.self),
    .field("paymentSource", PaymentSource?.self),
    .field("id", GraphAPI.ID.self),
    .field("isLatePledge", Bool.self),
    .field("location", Location?.self),
    .field("order", Order?.self),
    .field("paymentIncrements", [PaymentIncrement]?.self),
    .field("pledgedOn", GraphAPI.DateTime?.self),
    .field("project", Project?.self),
    .field("reward", Reward?.self),
    .field("rewardsAmount", RewardsAmount.self),
    .field("sequence", Int?.self),
    .field("shippingAmount", ShippingAmount?.self),
    .field("status", GraphQLEnum<GraphAPI.BackingState>.self),
    .field("backingDetailsPageRoute", String.self, arguments: [
      "type": "url",
      "tab": "survey_responses"
    ]),
  ] }

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

  public init(
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
    paymentIncrements: [PaymentIncrement]? = nil,
    pledgedOn: GraphAPI.DateTime? = nil,
    project: Project? = nil,
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
        "paymentIncrements": paymentIncrements._fieldData,
        "pledgedOn": pledgedOn,
        "project": project._fieldData,
        "reward": reward._fieldData,
        "rewardsAmount": rewardsAmount._fieldData,
        "sequence": sequence,
        "shippingAmount": shippingAmount._fieldData,
        "status": status,
        "backingDetailsPageRoute": backingDetailsPageRoute,
      ],
      fulfilledFragments: [
        ObjectIdentifier(BackingFragment.self)
      ]
    ))
  }

  /// Amount
  ///
  /// Parent Type: `Money`
  public struct Amount: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(MoneyFragment.self),
    ] }

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
          ObjectIdentifier(BackingFragment.Amount.self),
          ObjectIdentifier(MoneyFragment.self)
        ]
      ))
    }
  }

  /// Backer
  ///
  /// Parent Type: `User`
  public struct Backer: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(UserFragment.self),
    ] }

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

    public init(
      backings: Backings? = nil,
      backingsCount: Int,
      chosenCurrency: String? = nil,
      createdProjects: CreatedProjects? = nil,
      email: String? = nil,
      hasPassword: Bool? = nil,
      hasUnreadMessages: Bool? = nil,
      hasUnseenActivity: Bool? = nil,
      id: GraphAPI.ID,
      imageUrl: String,
      isAppleConnected: Bool? = nil,
      isBlocked: Bool? = nil,
      isCreator: Bool? = nil,
      isDeliverable: Bool? = nil,
      isEmailVerified: Bool? = nil,
      isFacebookConnected: Bool? = nil,
      isKsrAdmin: Bool? = nil,
      isFollowing: Bool,
      isSocializing: Bool? = nil,
      location: Location? = nil,
      name: String,
      needsFreshFacebookToken: Bool? = nil,
      newsletterSubscriptions: NewsletterSubscriptions? = nil,
      notifications: [Notification]? = nil,
      optedOutOfRecommendations: Bool? = nil,
      showPublicProfile: Bool? = nil,
      savedProjects: SavedProjects? = nil,
      storedCards: StoredCards? = nil,
      surveyResponses: SurveyResponses? = nil,
      uid: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.User.typename,
          "backings": backings._fieldData,
          "backingsCount": backingsCount,
          "chosenCurrency": chosenCurrency,
          "createdProjects": createdProjects._fieldData,
          "email": email,
          "hasPassword": hasPassword,
          "hasUnreadMessages": hasUnreadMessages,
          "hasUnseenActivity": hasUnseenActivity,
          "id": id,
          "imageUrl": imageUrl,
          "isAppleConnected": isAppleConnected,
          "isBlocked": isBlocked,
          "isCreator": isCreator,
          "isDeliverable": isDeliverable,
          "isEmailVerified": isEmailVerified,
          "isFacebookConnected": isFacebookConnected,
          "isKsrAdmin": isKsrAdmin,
          "isFollowing": isFollowing,
          "isSocializing": isSocializing,
          "location": location._fieldData,
          "name": name,
          "needsFreshFacebookToken": needsFreshFacebookToken,
          "newsletterSubscriptions": newsletterSubscriptions._fieldData,
          "notifications": notifications._fieldData,
          "optedOutOfRecommendations": optedOutOfRecommendations,
          "showPublicProfile": showPublicProfile,
          "savedProjects": savedProjects._fieldData,
          "storedCards": storedCards._fieldData,
          "surveyResponses": surveyResponses._fieldData,
          "uid": uid,
        ],
        fulfilledFragments: [
          ObjectIdentifier(BackingFragment.Backer.self),
          ObjectIdentifier(UserFragment.self)
        ]
      ))
    }

    public typealias Backings = UserFragment.Backings

    public typealias CreatedProjects = UserFragment.CreatedProjects

    /// Backer.Location
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
            ObjectIdentifier(BackingFragment.Backer.Location.self),
            ObjectIdentifier(UserFragment.Location.self),
            ObjectIdentifier(LocationFragment.self)
          ]
        ))
      }
    }

    public typealias NewsletterSubscriptions = UserFragment.NewsletterSubscriptions

    public typealias Notification = UserFragment.Notification

    public typealias SavedProjects = UserFragment.SavedProjects

    /// Backer.StoredCards
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

      public init(
        nodes: [Node?]? = nil,
        totalCount: Int
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.UserCreditCardTypeConnection.typename,
            "nodes": nodes._fieldData,
            "totalCount": totalCount,
          ],
          fulfilledFragments: [
            ObjectIdentifier(BackingFragment.Backer.StoredCards.self),
            ObjectIdentifier(UserFragment.StoredCards.self),
            ObjectIdentifier(UserStoredCardsFragment.self)
          ]
        ))
      }

      public typealias Node = UserStoredCardsFragment.Node
    }

    public typealias SurveyResponses = UserFragment.SurveyResponses
  }

  /// BonusAmount
  ///
  /// Parent Type: `Money`
  public struct BonusAmount: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(MoneyFragment.self),
    ] }

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
          ObjectIdentifier(BackingFragment.BonusAmount.self),
          ObjectIdentifier(MoneyFragment.self)
        ]
      ))
    }
  }

  /// PaymentSource
  ///
  /// Parent Type: `PaymentSource`
  public struct PaymentSource: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Unions.PaymentSource }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(PaymentSourceFragment.self),
    ] }

    public var asCreditCard: AsCreditCard? { _asInlineFragment() }
    public var asBankAccount: AsBankAccount? { _asInlineFragment() }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var paymentSourceFragment: PaymentSourceFragment { _toFragment() }
    }

    public init(
      __typename: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": __typename,
        ],
        fulfilledFragments: [
          ObjectIdentifier(BackingFragment.PaymentSource.self)
        ]
      ))
    }

    /// PaymentSource.AsCreditCard
    ///
    /// Parent Type: `CreditCard`
    public struct AsCreditCard: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = BackingFragment.PaymentSource
      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreditCard }
      public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        BackingFragment.PaymentSource.self,
        PaymentSourceFragment.AsCreditCard.self
      ] }

      /// When the credit card expires.
      public var expirationDate: GraphAPI.Date { __data["expirationDate"] }
      /// The card ID
      public var id: String { __data["id"] }
      /// The last four digits of the credit card number.
      public var lastFour: String { __data["lastFour"] }
      /// The card's payment type.
      public var paymentType: GraphQLEnum<GraphAPI.CreditCardPaymentType> { __data["paymentType"] }
      /// The card type.
      public var type: GraphQLEnum<GraphAPI.CreditCardTypes> { __data["type"] }
      /// Stripe card id
      public var stripeCardId: String { __data["stripeCardId"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var paymentSourceFragment: PaymentSourceFragment { _toFragment() }
      }

      public init(
        expirationDate: GraphAPI.Date,
        id: String,
        lastFour: String,
        paymentType: GraphQLEnum<GraphAPI.CreditCardPaymentType>,
        type: GraphQLEnum<GraphAPI.CreditCardTypes>,
        stripeCardId: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.CreditCard.typename,
            "expirationDate": expirationDate,
            "id": id,
            "lastFour": lastFour,
            "paymentType": paymentType,
            "type": type,
            "stripeCardId": stripeCardId,
          ],
          fulfilledFragments: [
            ObjectIdentifier(BackingFragment.PaymentSource.self),
            ObjectIdentifier(BackingFragment.PaymentSource.AsCreditCard.self),
            ObjectIdentifier(PaymentSourceFragment.self),
            ObjectIdentifier(PaymentSourceFragment.AsCreditCard.self)
          ]
        ))
      }
    }

    /// PaymentSource.AsBankAccount
    ///
    /// Parent Type: `BankAccount`
    public struct AsBankAccount: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = BackingFragment.PaymentSource
      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.BankAccount }
      public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        BackingFragment.PaymentSource.self,
        PaymentSourceFragment.AsBankAccount.self
      ] }

      public var id: String { __data["id"] }
      /// The last four digits of the account number.
      public var lastFour: String { __data["lastFour"] }
      /// The bank name if available.
      public var bankName: String? { __data["bankName"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var paymentSourceFragment: PaymentSourceFragment { _toFragment() }
      }

      public init(
        id: String,
        lastFour: String,
        bankName: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.BankAccount.typename,
            "id": id,
            "lastFour": lastFour,
            "bankName": bankName,
          ],
          fulfilledFragments: [
            ObjectIdentifier(BackingFragment.PaymentSource.self),
            ObjectIdentifier(BackingFragment.PaymentSource.AsBankAccount.self),
            ObjectIdentifier(PaymentSourceFragment.self),
            ObjectIdentifier(PaymentSourceFragment.AsBankAccount.self)
          ]
        ))
      }
    }
  }

  /// Location
  ///
  /// Parent Type: `Location`
  public struct Location: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Location }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(LocationFragment.self),
    ] }

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
          ObjectIdentifier(BackingFragment.Location.self),
          ObjectIdentifier(LocationFragment.self)
        ]
      ))
    }
  }

  /// Order
  ///
  /// Parent Type: `Order`
  public struct Order: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Order }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(OrderFragment.self),
    ] }

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
          ObjectIdentifier(BackingFragment.Order.self),
          ObjectIdentifier(OrderFragment.self)
        ]
      ))
    }
  }

  /// PaymentIncrement
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
    public var state: GraphQLEnum<GraphAPI.PaymentIncrementState> { __data["state"] }
    public var stateReason: GraphQLEnum<GraphAPI.PaymentIncrementStateReason>? { __data["stateReason"] }
    /// The total amount that has been refunded on the payment increment, across potentially multiple adjustments
    public var refundedAmount: RefundedAmount? { __data["refundedAmount"] }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var paymentIncrementFragment: PaymentIncrementFragment { _toFragment() }
    }

    public init(
      amount: Amount,
      scheduledCollection: GraphAPI.ISO8601DateTime,
      state: GraphQLEnum<GraphAPI.PaymentIncrementState>,
      stateReason: GraphQLEnum<GraphAPI.PaymentIncrementStateReason>? = nil,
      refundedAmount: RefundedAmount? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.PaymentIncrement.typename,
          "amount": amount._fieldData,
          "scheduledCollection": scheduledCollection,
          "state": state,
          "stateReason": stateReason,
          "refundedAmount": refundedAmount._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(BackingFragment.PaymentIncrement.self),
          ObjectIdentifier(PaymentIncrementFragment.self)
        ]
      ))
    }

    public typealias Amount = PaymentIncrementFragment.Amount

    public typealias RefundedAmount = PaymentIncrementFragment.RefundedAmount
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
      .fragment(ProjectFragment.self),
    ] }

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
    /// The last checkout_wave, if there is one
    public var lastWave: LastWave? { __data["lastWave"] }
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
    /// The project's pledge manager
    public var pledgeManager: PledgeManager? { __data["pledgeManager"] }
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
    /// URL for redeeming the backing
    public var redemptionPageUrl: String { __data["redemptionPageUrl"] }
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

    public init(
      availableCardTypes: [GraphQLEnum<GraphAPI.CreditCardTypes>],
      backersCount: Int,
      category: Category? = nil,
      canComment: Bool,
      commentsCount: Int,
      country: Country,
      creator: Creator? = nil,
      currency: GraphQLEnum<GraphAPI.CurrencyCode>,
      deadlineAt: GraphAPI.DateTime? = nil,
      description: String,
      environmentalCommitments: [EnvironmentalCommitment?]? = nil,
      aiDisclosure: AiDisclosure? = nil,
      faqs: Faqs? = nil,
      finalCollectionDate: GraphAPI.ISO8601DateTime? = nil,
      fxRate: Double,
      goal: Goal? = nil,
      image: Image? = nil,
      isPledgeOverTimeAllowed: Bool,
      isProjectWeLove: Bool,
      isProjectOfTheDay: Bool? = nil,
      isWatched: Bool,
      isLaunched: Bool,
      isInPostCampaignPledgingPhase: Bool,
      lastWave: LastWave? = nil,
      launchedAt: GraphAPI.DateTime? = nil,
      location: Location? = nil,
      maxPledge: Int,
      minPledge: Int,
      name: String,
      pid: Int,
      pledgeManager: PledgeManager? = nil,
      pledgeOverTimeCollectionPlanChargeExplanation: String? = nil,
      pledgeOverTimeCollectionPlanChargedAsNPayments: String? = nil,
      pledgeOverTimeCollectionPlanShortPitch: String? = nil,
      pledgeOverTimeMinimumExplanation: String? = nil,
      pledged: Pledged,
      postCampaignPledgingEnabled: Bool,
      posts: Posts? = nil,
      prelaunchActivated: Bool,
      projectNotice: String? = nil,
      redemptionPageUrl: String,
      risks: String,
      sendMetaCapiEvents: Bool,
      slug: String,
      state: GraphQLEnum<GraphAPI.ProjectState>,
      stateChangedAt: GraphAPI.DateTime,
      story: GraphAPI.HTML,
      tags: [Tag?],
      url: String,
      usdExchangeRate: Double? = nil,
      video: Video? = nil,
      watchesCount: Int? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Project.typename,
          "availableCardTypes": availableCardTypes,
          "backersCount": backersCount,
          "category": category._fieldData,
          "canComment": canComment,
          "commentsCount": commentsCount,
          "country": country._fieldData,
          "creator": creator._fieldData,
          "currency": currency,
          "deadlineAt": deadlineAt,
          "description": description,
          "environmentalCommitments": environmentalCommitments._fieldData,
          "aiDisclosure": aiDisclosure._fieldData,
          "faqs": faqs._fieldData,
          "finalCollectionDate": finalCollectionDate,
          "fxRate": fxRate,
          "goal": goal._fieldData,
          "image": image._fieldData,
          "isPledgeOverTimeAllowed": isPledgeOverTimeAllowed,
          "isProjectWeLove": isProjectWeLove,
          "isProjectOfTheDay": isProjectOfTheDay,
          "isWatched": isWatched,
          "isLaunched": isLaunched,
          "isInPostCampaignPledgingPhase": isInPostCampaignPledgingPhase,
          "lastWave": lastWave._fieldData,
          "launchedAt": launchedAt,
          "location": location._fieldData,
          "maxPledge": maxPledge,
          "minPledge": minPledge,
          "name": name,
          "pid": pid,
          "pledgeManager": pledgeManager._fieldData,
          "pledgeOverTimeCollectionPlanChargeExplanation": pledgeOverTimeCollectionPlanChargeExplanation,
          "pledgeOverTimeCollectionPlanChargedAsNPayments": pledgeOverTimeCollectionPlanChargedAsNPayments,
          "pledgeOverTimeCollectionPlanShortPitch": pledgeOverTimeCollectionPlanShortPitch,
          "pledgeOverTimeMinimumExplanation": pledgeOverTimeMinimumExplanation,
          "pledged": pledged._fieldData,
          "postCampaignPledgingEnabled": postCampaignPledgingEnabled,
          "posts": posts._fieldData,
          "prelaunchActivated": prelaunchActivated,
          "projectNotice": projectNotice,
          "redemptionPageUrl": redemptionPageUrl,
          "risks": risks,
          "sendMetaCapiEvents": sendMetaCapiEvents,
          "slug": slug,
          "state": state,
          "stateChangedAt": stateChangedAt,
          "story": story,
          "tags": tags._fieldData,
          "url": url,
          "usdExchangeRate": usdExchangeRate,
          "video": video._fieldData,
          "watchesCount": watchesCount,
        ],
        fulfilledFragments: [
          ObjectIdentifier(BackingFragment.Project.self),
          ObjectIdentifier(ProjectFragment.self)
        ]
      ))
    }

    /// Project.Category
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
            ObjectIdentifier(BackingFragment.Project.Category.self),
            ObjectIdentifier(ProjectFragment.Category.self),
            ObjectIdentifier(CategoryFragment.self)
          ]
        ))
      }

      public typealias ParentCategory = CategoryFragment.ParentCategory
    }

    /// Project.Country
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
            ObjectIdentifier(BackingFragment.Project.Country.self),
            ObjectIdentifier(ProjectFragment.Country.self),
            ObjectIdentifier(CountryFragment.self)
          ]
        ))
      }
    }

    /// Project.Creator
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

      public init(
        backings: Backings? = nil,
        backingsCount: Int,
        chosenCurrency: String? = nil,
        createdProjects: CreatedProjects? = nil,
        email: String? = nil,
        hasPassword: Bool? = nil,
        hasUnreadMessages: Bool? = nil,
        hasUnseenActivity: Bool? = nil,
        id: GraphAPI.ID,
        imageUrl: String,
        isAppleConnected: Bool? = nil,
        isBlocked: Bool? = nil,
        isCreator: Bool? = nil,
        isDeliverable: Bool? = nil,
        isEmailVerified: Bool? = nil,
        isFacebookConnected: Bool? = nil,
        isKsrAdmin: Bool? = nil,
        isFollowing: Bool,
        isSocializing: Bool? = nil,
        location: Location? = nil,
        name: String,
        needsFreshFacebookToken: Bool? = nil,
        newsletterSubscriptions: NewsletterSubscriptions? = nil,
        notifications: [Notification]? = nil,
        optedOutOfRecommendations: Bool? = nil,
        showPublicProfile: Bool? = nil,
        savedProjects: SavedProjects? = nil,
        storedCards: StoredCards? = nil,
        surveyResponses: SurveyResponses? = nil,
        uid: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.User.typename,
            "backings": backings._fieldData,
            "backingsCount": backingsCount,
            "chosenCurrency": chosenCurrency,
            "createdProjects": createdProjects._fieldData,
            "email": email,
            "hasPassword": hasPassword,
            "hasUnreadMessages": hasUnreadMessages,
            "hasUnseenActivity": hasUnseenActivity,
            "id": id,
            "imageUrl": imageUrl,
            "isAppleConnected": isAppleConnected,
            "isBlocked": isBlocked,
            "isCreator": isCreator,
            "isDeliverable": isDeliverable,
            "isEmailVerified": isEmailVerified,
            "isFacebookConnected": isFacebookConnected,
            "isKsrAdmin": isKsrAdmin,
            "isFollowing": isFollowing,
            "isSocializing": isSocializing,
            "location": location._fieldData,
            "name": name,
            "needsFreshFacebookToken": needsFreshFacebookToken,
            "newsletterSubscriptions": newsletterSubscriptions._fieldData,
            "notifications": notifications._fieldData,
            "optedOutOfRecommendations": optedOutOfRecommendations,
            "showPublicProfile": showPublicProfile,
            "savedProjects": savedProjects._fieldData,
            "storedCards": storedCards._fieldData,
            "surveyResponses": surveyResponses._fieldData,
            "uid": uid,
          ],
          fulfilledFragments: [
            ObjectIdentifier(BackingFragment.Project.Creator.self),
            ObjectIdentifier(ProjectFragment.Creator.self),
            ObjectIdentifier(UserFragment.self)
          ]
        ))
      }

      public typealias Backings = UserFragment.Backings

      public typealias CreatedProjects = UserFragment.CreatedProjects

      /// Project.Creator.Location
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
              ObjectIdentifier(BackingFragment.Project.Creator.Location.self),
              ObjectIdentifier(UserFragment.Location.self),
              ObjectIdentifier(LocationFragment.self)
            ]
          ))
        }
      }

      public typealias NewsletterSubscriptions = UserFragment.NewsletterSubscriptions

      public typealias Notification = UserFragment.Notification

      public typealias SavedProjects = UserFragment.SavedProjects

      /// Project.Creator.StoredCards
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

        public init(
          nodes: [Node?]? = nil,
          totalCount: Int
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.UserCreditCardTypeConnection.typename,
              "nodes": nodes._fieldData,
              "totalCount": totalCount,
            ],
            fulfilledFragments: [
              ObjectIdentifier(BackingFragment.Project.Creator.StoredCards.self),
              ObjectIdentifier(UserFragment.StoredCards.self),
              ObjectIdentifier(UserStoredCardsFragment.self)
            ]
          ))
        }

        public typealias Node = UserStoredCardsFragment.Node
      }

      public typealias SurveyResponses = UserFragment.SurveyResponses
    }

    public typealias EnvironmentalCommitment = ProjectFragment.EnvironmentalCommitment

    public typealias AiDisclosure = ProjectFragment.AiDisclosure

    public typealias Faqs = ProjectFragment.Faqs

    /// Project.Goal
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
            ObjectIdentifier(BackingFragment.Project.Goal.self),
            ObjectIdentifier(ProjectFragment.Goal.self),
            ObjectIdentifier(MoneyFragment.self)
          ]
        ))
      }
    }

    public typealias Image = ProjectFragment.Image

    /// Project.LastWave
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
            ObjectIdentifier(BackingFragment.Project.LastWave.self),
            ObjectIdentifier(ProjectFragment.LastWave.self),
            ObjectIdentifier(LastWaveFragment.self)
          ]
        ))
      }
    }

    /// Project.Location
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
            ObjectIdentifier(BackingFragment.Project.Location.self),
            ObjectIdentifier(ProjectFragment.Location.self),
            ObjectIdentifier(LocationFragment.self)
          ]
        ))
      }
    }

    /// Project.PledgeManager
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
            ObjectIdentifier(BackingFragment.Project.PledgeManager.self),
            ObjectIdentifier(ProjectFragment.PledgeManager.self),
            ObjectIdentifier(PledgeManagerFragment.self)
          ]
        ))
      }
    }

    /// Project.Pledged
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
            ObjectIdentifier(BackingFragment.Project.Pledged.self),
            ObjectIdentifier(ProjectFragment.Pledged.self),
            ObjectIdentifier(MoneyFragment.self)
          ]
        ))
      }
    }

    public typealias Posts = ProjectFragment.Posts

    public typealias Tag = ProjectFragment.Tag

    public typealias Video = ProjectFragment.Video
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
          ObjectIdentifier(BackingFragment.Reward.self),
          ObjectIdentifier(RewardFragment.self)
        ]
      ))
    }

    /// Reward.Amount
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
            ObjectIdentifier(BackingFragment.Reward.Amount.self),
            ObjectIdentifier(RewardFragment.Amount.self),
            ObjectIdentifier(MoneyFragment.self)
          ]
        ))
      }
    }

    /// Reward.ConvertedAmount
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
            ObjectIdentifier(BackingFragment.Reward.ConvertedAmount.self),
            ObjectIdentifier(RewardFragment.ConvertedAmount.self),
            ObjectIdentifier(MoneyFragment.self)
          ]
        ))
      }
    }

    public typealias AllowedAddons = RewardFragment.AllowedAddons

    public typealias Items = RewardFragment.Items

    /// Reward.LocalReceiptLocation
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
            ObjectIdentifier(BackingFragment.Reward.LocalReceiptLocation.self),
            ObjectIdentifier(RewardFragment.LocalReceiptLocation.self),
            ObjectIdentifier(LocationFragment.self)
          ]
        ))
      }
    }

    /// Reward.PledgeAmount
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
            ObjectIdentifier(BackingFragment.Reward.PledgeAmount.self),
            ObjectIdentifier(RewardFragment.PledgeAmount.self),
            ObjectIdentifier(MoneyFragment.self)
          ]
        ))
      }
    }

    /// Reward.LatePledgeAmount
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
            ObjectIdentifier(BackingFragment.Reward.LatePledgeAmount.self),
            ObjectIdentifier(RewardFragment.LatePledgeAmount.self),
            ObjectIdentifier(MoneyFragment.self)
          ]
        ))
      }
    }

    public typealias Project = RewardFragment.Project

    /// Reward.ShippingRule
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
            ObjectIdentifier(BackingFragment.Reward.ShippingRule.self),
            ObjectIdentifier(RewardFragment.ShippingRule.self),
            ObjectIdentifier(ShippingRuleFragment.self)
          ]
        ))
      }

      /// Reward.ShippingRule.Cost
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
              ObjectIdentifier(BackingFragment.Reward.ShippingRule.Cost.self),
              ObjectIdentifier(ShippingRuleFragment.Cost.self),
              ObjectIdentifier(MoneyFragment.self)
            ]
          ))
        }
      }

      /// Reward.ShippingRule.Location
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
              ObjectIdentifier(BackingFragment.Reward.ShippingRule.Location.self),
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

  /// RewardsAmount
  ///
  /// Parent Type: `Money`
  public struct RewardsAmount: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(MoneyFragment.self),
    ] }

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
          ObjectIdentifier(BackingFragment.RewardsAmount.self),
          ObjectIdentifier(MoneyFragment.self)
        ]
      ))
    }
  }

  /// ShippingAmount
  ///
  /// Parent Type: `Money`
  public struct ShippingAmount: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(MoneyFragment.self),
    ] }

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
          ObjectIdentifier(BackingFragment.ShippingAmount.self),
          ObjectIdentifier(MoneyFragment.self)
        ]
      ))
    }
  }
}
