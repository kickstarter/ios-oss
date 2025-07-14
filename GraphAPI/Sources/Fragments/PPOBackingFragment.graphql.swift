// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PPOBackingFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PPOBackingFragment on Backing { __typename amount { __typename ...MoneyFragment } id project { __typename ...PPOProjectFragment ...ProjectAnalyticsFragment } backingDetailsPageRoute(type: url, tab: survey_responses) deliveryAddress { __typename id addressLine1 addressLine2 city region postalCode phoneNumber recipientName countryCode } clientSecret }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Backing }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("amount", Amount.self),
    .field("id", GraphAPI.ID.self),
    .field("project", Project?.self),
    .field("backingDetailsPageRoute", String.self, arguments: [
      "type": "url",
      "tab": "survey_responses"
    ]),
    .field("deliveryAddress", DeliveryAddress?.self),
    .field("clientSecret", String?.self),
  ] }

  /// Total amount pledged by the backer to the project, including shipping.
  public var amount: Amount { __data["amount"] }
  public var id: GraphAPI.ID { __data["id"] }
  /// The project
  public var project: Project? { __data["project"] }
  /// URL/path for the backing details page
  public var backingDetailsPageRoute: String { __data["backingDetailsPageRoute"] }
  /// The delivery address associated with the backing
  public var deliveryAddress: DeliveryAddress? { __data["deliveryAddress"] }
  /// If `requires_action` is true, `client_secret` should be used to initiate additional client-side authentication steps
  public var clientSecret: String? { __data["clientSecret"] }

  public init(
    amount: Amount,
    id: GraphAPI.ID,
    project: Project? = nil,
    backingDetailsPageRoute: String,
    deliveryAddress: DeliveryAddress? = nil,
    clientSecret: String? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Backing.typename,
        "amount": amount._fieldData,
        "id": id,
        "project": project._fieldData,
        "backingDetailsPageRoute": backingDetailsPageRoute,
        "deliveryAddress": deliveryAddress._fieldData,
        "clientSecret": clientSecret,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PPOBackingFragment.self)
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
          ObjectIdentifier(PPOBackingFragment.Amount.self),
          ObjectIdentifier(MoneyFragment.self)
        ]
      ))
    }
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
      .fragment(PPOProjectFragment.self),
      .fragment(ProjectAnalyticsFragment.self),
    ] }

    /// The project's creator.
    public var creator: Creator? { __data["creator"] }
    /// The project's primary image.
    public var image: Image? { __data["image"] }
    /// The project's name.
    public var name: String { __data["name"] }
    /// The project's pid.
    public var pid: Int { __data["pid"] }
    /// The project's unique URL identifier.
    public var slug: String { __data["slug"] }
    /// Backing Add-ons
    public var addOns: AddOns? { __data["addOns"] }
    /// Total backers for the project
    public var backersCount: Int { __data["backersCount"] }
    /// The current user's backing of this project.  Does not include inactive backings.
    public var backing: Backing? { __data["backing"] }
    /// The project's category.
    public var category: Category? { __data["category"] }
    /// Comment count - defaults to root level comments only
    public var commentsCount: Int { __data["commentsCount"] }
    /// The project's country
    public var country: Country { __data["country"] }
    /// The project's currency code.
    public var currency: GraphQLEnum<GraphAPI.CurrencyCode> { __data["currency"] }
    /// When is the project scheduled to end?
    public var deadlineAt: GraphAPI.DateTime? { __data["deadlineAt"] }
    /// When the project launched
    public var launchedAt: GraphAPI.DateTime? { __data["launchedAt"] }
    /// Is this project currently accepting post-campaign pledges?
    public var isInPostCampaignPledgingPhase: Bool { __data["isInPostCampaignPledgingPhase"] }
    /// Is the current user watching this project?
    public var isWatched: Bool { __data["isWatched"] }
    /// What percent the project has towards meeting its funding goal.
    public var percentFunded: Int { __data["percentFunded"] }
    /// Whether a project has activated prelaunch.
    public var isPrelaunchActivated: Bool { __data["isPrelaunchActivated"] }
    /// Tags project has been tagged with
    public var projectTags: [ProjectTag?] { __data["projectTags"] }
    /// Is this project configured for post-campaign pledges?
    public var postCampaignPledgingEnabled: Bool { __data["postCampaignPledgingEnabled"] }
    /// Project rewards.
    public var rewards: Rewards? { __data["rewards"] }
    /// The project's current state.
    public var state: GraphQLEnum<GraphAPI.ProjectState> { __data["state"] }
    /// A project video.
    public var video: Video? { __data["video"] }
    /// How much money is pledged to the project.
    public var pledged: Pledged { __data["pledged"] }
    /// Exchange rate for the current user's currency
    public var fxRate: Double { __data["fxRate"] }
    /// Exchange rate to US Dollars (USD), null for draft projects.
    public var usdExchangeRate: Double? { __data["usdExchangeRate"] }
    /// Project updates.
    public var posts: Posts? { __data["posts"] }
    /// The minimum amount to raise for the project to be successful.
    public var goal: Goal? { __data["goal"] }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var pPOProjectFragment: PPOProjectFragment { _toFragment() }
      public var projectAnalyticsFragment: ProjectAnalyticsFragment { _toFragment() }
    }

    public init(
      creator: Creator? = nil,
      image: Image? = nil,
      name: String,
      pid: Int,
      slug: String,
      addOns: AddOns? = nil,
      backersCount: Int,
      backing: Backing? = nil,
      category: Category? = nil,
      commentsCount: Int,
      country: Country,
      currency: GraphQLEnum<GraphAPI.CurrencyCode>,
      deadlineAt: GraphAPI.DateTime? = nil,
      launchedAt: GraphAPI.DateTime? = nil,
      isInPostCampaignPledgingPhase: Bool,
      isWatched: Bool,
      percentFunded: Int,
      isPrelaunchActivated: Bool,
      projectTags: [ProjectTag?],
      postCampaignPledgingEnabled: Bool,
      rewards: Rewards? = nil,
      state: GraphQLEnum<GraphAPI.ProjectState>,
      video: Video? = nil,
      pledged: Pledged,
      fxRate: Double,
      usdExchangeRate: Double? = nil,
      posts: Posts? = nil,
      goal: Goal? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Project.typename,
          "creator": creator._fieldData,
          "image": image._fieldData,
          "name": name,
          "pid": pid,
          "slug": slug,
          "addOns": addOns._fieldData,
          "backersCount": backersCount,
          "backing": backing._fieldData,
          "category": category._fieldData,
          "commentsCount": commentsCount,
          "country": country._fieldData,
          "currency": currency,
          "deadlineAt": deadlineAt,
          "launchedAt": launchedAt,
          "isInPostCampaignPledgingPhase": isInPostCampaignPledgingPhase,
          "isWatched": isWatched,
          "percentFunded": percentFunded,
          "isPrelaunchActivated": isPrelaunchActivated,
          "projectTags": projectTags._fieldData,
          "postCampaignPledgingEnabled": postCampaignPledgingEnabled,
          "rewards": rewards._fieldData,
          "state": state,
          "video": video._fieldData,
          "pledged": pledged._fieldData,
          "fxRate": fxRate,
          "usdExchangeRate": usdExchangeRate,
          "posts": posts._fieldData,
          "goal": goal._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PPOBackingFragment.Project.self),
          ObjectIdentifier(PPOProjectFragment.self),
          ObjectIdentifier(ProjectAnalyticsFragment.self)
        ]
      ))
    }

    /// Project.Creator
    ///
    /// Parent Type: `User`
    public struct Creator: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }

      /// A user's email address.
      public var email: String? { __data["email"] }
      public var id: GraphAPI.ID { __data["id"] }
      /// The user's provided name.
      public var name: String { __data["name"] }
      /// Projects a user has created.
      public var createdProjects: CreatedProjects? { __data["createdProjects"] }

      public init(
        email: String? = nil,
        id: GraphAPI.ID,
        name: String,
        createdProjects: CreatedProjects? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.User.typename,
            "email": email,
            "id": id,
            "name": name,
            "createdProjects": createdProjects._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(PPOBackingFragment.Project.Creator.self),
            ObjectIdentifier(PPOProjectFragment.Creator.self),
            ObjectIdentifier(ProjectAnalyticsFragment.Creator.self)
          ]
        ))
      }

      public typealias CreatedProjects = ProjectAnalyticsFragment.Creator.CreatedProjects
    }

    public typealias Image = PPOProjectFragment.Image

    public typealias AddOns = ProjectAnalyticsFragment.AddOns

    public typealias Backing = ProjectAnalyticsFragment.Backing

    public typealias Category = ProjectAnalyticsFragment.Category

    public typealias Country = ProjectAnalyticsFragment.Country

    public typealias ProjectTag = ProjectAnalyticsFragment.ProjectTag

    public typealias Rewards = ProjectAnalyticsFragment.Rewards

    public typealias Video = ProjectAnalyticsFragment.Video

    public typealias Pledged = ProjectAnalyticsFragment.Pledged

    public typealias Posts = ProjectAnalyticsFragment.Posts

    public typealias Goal = ProjectAnalyticsFragment.Goal
  }

  /// DeliveryAddress
  ///
  /// Parent Type: `Address`
  public struct DeliveryAddress: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Address }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", GraphAPI.ID.self),
      .field("addressLine1", String.self),
      .field("addressLine2", String?.self),
      .field("city", String.self),
      .field("region", String?.self),
      .field("postalCode", String?.self),
      .field("phoneNumber", String?.self),
      .field("recipientName", String?.self),
      .field("countryCode", GraphQLEnum<GraphAPI.CountryCode>.self),
    ] }

    public var id: GraphAPI.ID { __data["id"] }
    /// Address line 1 (Street address/PO Box/Company name)
    public var addressLine1: String { __data["addressLine1"] }
    /// Address line 2 (Apartment/Suite/Unit/Building)
    public var addressLine2: String? { __data["addressLine2"] }
    /// City
    public var city: String { __data["city"] }
    /// State/County/Province/Region.
    public var region: String? { __data["region"] }
    /// ZIP or postal code
    public var postalCode: String? { __data["postalCode"] }
    /// Recipient's phone number
    public var phoneNumber: String? { __data["phoneNumber"] }
    /// Address recipient name
    public var recipientName: String? { __data["recipientName"] }
    /// 2-letter country code
    public var countryCode: GraphQLEnum<GraphAPI.CountryCode> { __data["countryCode"] }

    public init(
      id: GraphAPI.ID,
      addressLine1: String,
      addressLine2: String? = nil,
      city: String,
      region: String? = nil,
      postalCode: String? = nil,
      phoneNumber: String? = nil,
      recipientName: String? = nil,
      countryCode: GraphQLEnum<GraphAPI.CountryCode>
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Address.typename,
          "id": id,
          "addressLine1": addressLine1,
          "addressLine2": addressLine2,
          "city": city,
          "region": region,
          "postalCode": postalCode,
          "phoneNumber": phoneNumber,
          "recipientName": recipientName,
          "countryCode": countryCode,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PPOBackingFragment.DeliveryAddress.self)
        ]
      ))
    }
  }
}
