// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PPOCardFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PPOCardFragment on PledgeProjectOverviewItem { __typename backing { __typename ...PPOBackingFragment } tierType flags { __typename icon message type } webviewUrl }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PledgeProjectOverviewItem }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("backing", Backing?.self),
    .field("tierType", String?.self),
    .field("flags", [Flag]?.self),
    .field("webviewUrl", String?.self),
  ] }

  /// backing details
  public var backing: Backing? { __data["backing"] }
  /// tier type
  public var tierType: String? { __data["tierType"] }
  /// tags
  public var flags: [Flag]? { __data["flags"] }
  /// webview url for survey responses or pledge management
  public var webviewUrl: String? { __data["webviewUrl"] }

  public init(
    backing: Backing? = nil,
    tierType: String? = nil,
    flags: [Flag]? = nil,
    webviewUrl: String? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.PledgeProjectOverviewItem.typename,
        "backing": backing._fieldData,
        "tierType": tierType,
        "flags": flags._fieldData,
        "webviewUrl": webviewUrl,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PPOCardFragment.self)
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
      .fragment(PPOBackingFragment.self),
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

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var pPOBackingFragment: PPOBackingFragment { _toFragment() }
    }

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
          ObjectIdentifier(PPOCardFragment.Backing.self),
          ObjectIdentifier(PPOBackingFragment.self)
        ]
      ))
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
            ObjectIdentifier(PPOCardFragment.Backing.Amount.self),
            ObjectIdentifier(PPOBackingFragment.Amount.self),
            ObjectIdentifier(MoneyFragment.self)
          ]
        ))
      }
    }

    /// Backing.Project
    ///
    /// Parent Type: `Project`
    public struct Project: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }

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
            ObjectIdentifier(PPOCardFragment.Backing.Project.self),
            ObjectIdentifier(PPOBackingFragment.Project.self),
            ObjectIdentifier(PPOProjectFragment.self),
            ObjectIdentifier(ProjectAnalyticsFragment.self)
          ]
        ))
      }

      /// Backing.Project.Creator
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
              ObjectIdentifier(PPOCardFragment.Backing.Project.Creator.self),
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

    public typealias DeliveryAddress = PPOBackingFragment.DeliveryAddress
  }

  /// Flag
  ///
  /// Parent Type: `PledgedProjectsOverviewPledgeFlags`
  public struct Flag: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PledgedProjectsOverviewPledgeFlags }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("icon", String?.self),
      .field("message", String?.self),
      .field("type", String?.self),
    ] }

    /// Flag icon type, e.g. time, alert, etc.
    public var icon: String? { __data["icon"] }
    /// Translated flag message
    public var message: String? { __data["message"] }
    /// Flag type, e.g. warning, alert, etc.
    public var type: String? { __data["type"] }

    public init(
      icon: String? = nil,
      message: String? = nil,
      type: String? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.PledgedProjectsOverviewPledgeFlags.typename,
          "icon": icon,
          "message": message,
          "type": type,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PPOCardFragment.Flag.self)
        ]
      ))
    }
  }
}
