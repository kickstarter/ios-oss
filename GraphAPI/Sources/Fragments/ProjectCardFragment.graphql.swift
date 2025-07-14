// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ProjectCardFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ProjectCardFragment on Project { __typename image { __typename id url(width: 1024) } pid name state isLaunched deadlineAt percentFunded prelaunchActivated launchedAt isInPostCampaignPledgingPhase postCampaignPledgingEnabled url isWatched goal { __typename ...MoneyFragment } pledged { __typename ...MoneyFragment } ...ProjectAnalyticsFragment ...ProjectPamphletMainCellPropertiesFragment }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("image", Image?.self),
    .field("pid", Int.self),
    .field("name", String.self),
    .field("state", GraphQLEnum<GraphAPI.ProjectState>.self),
    .field("isLaunched", Bool.self),
    .field("deadlineAt", GraphAPI.DateTime?.self),
    .field("percentFunded", Int.self),
    .field("prelaunchActivated", Bool.self),
    .field("launchedAt", GraphAPI.DateTime?.self),
    .field("isInPostCampaignPledgingPhase", Bool.self),
    .field("postCampaignPledgingEnabled", Bool.self),
    .field("url", String.self),
    .field("isWatched", Bool.self),
    .field("goal", Goal?.self),
    .field("pledged", Pledged.self),
    .fragment(ProjectAnalyticsFragment.self),
    .fragment(ProjectPamphletMainCellPropertiesFragment.self),
  ] }

  /// The project's primary image.
  public var image: Image? { __data["image"] }
  /// The project's pid.
  public var pid: Int { __data["pid"] }
  /// The project's name.
  public var name: String { __data["name"] }
  /// The project's current state.
  public var state: GraphQLEnum<GraphAPI.ProjectState> { __data["state"] }
  /// The project has launched
  public var isLaunched: Bool { __data["isLaunched"] }
  /// When is the project scheduled to end?
  public var deadlineAt: GraphAPI.DateTime? { __data["deadlineAt"] }
  /// What percent the project has towards meeting its funding goal.
  public var percentFunded: Int { __data["percentFunded"] }
  /// Whether a project has activated prelaunch.
  public var prelaunchActivated: Bool { __data["prelaunchActivated"] }
  /// When the project launched
  public var launchedAt: GraphAPI.DateTime? { __data["launchedAt"] }
  /// Is this project currently accepting post-campaign pledges?
  public var isInPostCampaignPledgingPhase: Bool { __data["isInPostCampaignPledgingPhase"] }
  /// Is this project configured for post-campaign pledges?
  public var postCampaignPledgingEnabled: Bool { __data["postCampaignPledgingEnabled"] }
  /// A URL to the project's page.
  public var url: String { __data["url"] }
  /// Is the current user watching this project?
  public var isWatched: Bool { __data["isWatched"] }
  /// The minimum amount to raise for the project to be successful.
  public var goal: Goal? { __data["goal"] }
  /// How much money is pledged to the project.
  public var pledged: Pledged { __data["pledged"] }
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
  /// The project's creator.
  public var creator: Creator? { __data["creator"] }
  /// The project's currency code.
  public var currency: GraphQLEnum<GraphAPI.CurrencyCode> { __data["currency"] }
  /// Whether a project has activated prelaunch.
  public var isPrelaunchActivated: Bool { __data["isPrelaunchActivated"] }
  /// Tags project has been tagged with
  public var projectTags: [ProjectTag?] { __data["projectTags"] }
  /// Project rewards.
  public var rewards: Rewards? { __data["rewards"] }
  /// A project video.
  public var video: Video? { __data["video"] }
  /// Exchange rate for the current user's currency
  public var fxRate: Double { __data["fxRate"] }
  /// Exchange rate to US Dollars (USD), null for draft projects.
  public var usdExchangeRate: Double? { __data["usdExchangeRate"] }
  /// Project updates.
  public var posts: Posts? { __data["posts"] }
  /// A short description of the project.
  public var projectDescription: String { __data["projectDescription"] }
  /// The last time a project's state changed, time since epoch
  public var stateChangedAt: GraphAPI.DateTime { __data["stateChangedAt"] }
  /// Exchange rate to US Dollars (USD) for the project's currency
  public var projectUsdExchangeRate: Double { __data["projectUsdExchangeRate"] }
  /// Where the project is based.
  public var location: Location? { __data["location"] }
  /// Potential hurdles to project completion.
  public var risks: String { __data["risks"] }

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public var projectAnalyticsFragment: ProjectAnalyticsFragment { _toFragment() }
    public var projectPamphletMainCellPropertiesFragment: ProjectPamphletMainCellPropertiesFragment { _toFragment() }
  }

  public init(
    image: Image? = nil,
    pid: Int,
    name: String,
    state: GraphQLEnum<GraphAPI.ProjectState>,
    isLaunched: Bool,
    deadlineAt: GraphAPI.DateTime? = nil,
    percentFunded: Int,
    prelaunchActivated: Bool,
    launchedAt: GraphAPI.DateTime? = nil,
    isInPostCampaignPledgingPhase: Bool,
    postCampaignPledgingEnabled: Bool,
    url: String,
    isWatched: Bool,
    goal: Goal? = nil,
    pledged: Pledged,
    addOns: AddOns? = nil,
    backersCount: Int,
    backing: Backing? = nil,
    category: Category? = nil,
    commentsCount: Int,
    country: Country,
    creator: Creator? = nil,
    currency: GraphQLEnum<GraphAPI.CurrencyCode>,
    isPrelaunchActivated: Bool,
    projectTags: [ProjectTag?],
    rewards: Rewards? = nil,
    video: Video? = nil,
    fxRate: Double,
    usdExchangeRate: Double? = nil,
    posts: Posts? = nil,
    projectDescription: String,
    stateChangedAt: GraphAPI.DateTime,
    projectUsdExchangeRate: Double,
    location: Location? = nil,
    risks: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Project.typename,
        "image": image._fieldData,
        "pid": pid,
        "name": name,
        "state": state,
        "isLaunched": isLaunched,
        "deadlineAt": deadlineAt,
        "percentFunded": percentFunded,
        "prelaunchActivated": prelaunchActivated,
        "launchedAt": launchedAt,
        "isInPostCampaignPledgingPhase": isInPostCampaignPledgingPhase,
        "postCampaignPledgingEnabled": postCampaignPledgingEnabled,
        "url": url,
        "isWatched": isWatched,
        "goal": goal._fieldData,
        "pledged": pledged._fieldData,
        "addOns": addOns._fieldData,
        "backersCount": backersCount,
        "backing": backing._fieldData,
        "category": category._fieldData,
        "commentsCount": commentsCount,
        "country": country._fieldData,
        "creator": creator._fieldData,
        "currency": currency,
        "isPrelaunchActivated": isPrelaunchActivated,
        "projectTags": projectTags._fieldData,
        "rewards": rewards._fieldData,
        "video": video._fieldData,
        "fxRate": fxRate,
        "usdExchangeRate": usdExchangeRate,
        "posts": posts._fieldData,
        "projectDescription": projectDescription,
        "stateChangedAt": stateChangedAt,
        "projectUsdExchangeRate": projectUsdExchangeRate,
        "location": location._fieldData,
        "risks": risks,
      ],
      fulfilledFragments: [
        ObjectIdentifier(ProjectCardFragment.self),
        ObjectIdentifier(ProjectAnalyticsFragment.self),
        ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.self)
      ]
    ))
  }

  /// Image
  ///
  /// Parent Type: `Photo`
  public struct Image: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Photo }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", GraphAPI.ID.self),
      .field("url", String.self, arguments: ["width": 1024]),
    ] }

    public var id: GraphAPI.ID { __data["id"] }
    /// URL of the photo
    public var url: String { __data["url"] }

    public init(
      id: GraphAPI.ID,
      url: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Photo.typename,
          "id": id,
          "url": url,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectCardFragment.Image.self)
        ]
      ))
    }
  }

  /// Goal
  ///
  /// Parent Type: `Money`
  public struct Goal: GraphAPI.SelectionSet {
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
          ObjectIdentifier(ProjectCardFragment.Goal.self),
          ObjectIdentifier(MoneyFragment.self),
          ObjectIdentifier(ProjectAnalyticsFragment.Goal.self)
        ]
      ))
    }
  }

  /// Pledged
  ///
  /// Parent Type: `Money`
  public struct Pledged: GraphAPI.SelectionSet {
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
          ObjectIdentifier(ProjectCardFragment.Pledged.self),
          ObjectIdentifier(MoneyFragment.self),
          ObjectIdentifier(ProjectAnalyticsFragment.Pledged.self)
        ]
      ))
    }
  }

  public typealias AddOns = ProjectAnalyticsFragment.AddOns

  /// Backing
  ///
  /// Parent Type: `Backing`
  public struct Backing: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Backing }

    public var id: GraphAPI.ID { __data["id"] }

    public init(
      id: GraphAPI.ID
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Backing.typename,
          "id": id,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectCardFragment.Backing.self),
          ObjectIdentifier(ProjectAnalyticsFragment.Backing.self),
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Backing.self)
        ]
      ))
    }
  }

  /// Category
  ///
  /// Parent Type: `Category`
  public struct Category: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Category }

    /// Category name in English for analytics use.
    public var analyticsName: String { __data["analyticsName"] }
    /// Category parent
    public var parentCategory: ParentCategory? { __data["parentCategory"] }
    /// Category name.
    public var name: String { __data["name"] }

    public init(
      analyticsName: String,
      parentCategory: ParentCategory? = nil,
      name: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Category.typename,
          "analyticsName": analyticsName,
          "parentCategory": parentCategory._fieldData,
          "name": name,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectCardFragment.Category.self),
          ObjectIdentifier(ProjectAnalyticsFragment.Category.self),
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Category.self)
        ]
      ))
    }

    public typealias ParentCategory = ProjectAnalyticsFragment.Category.ParentCategory
  }

  /// Country
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
          ObjectIdentifier(ProjectCardFragment.Country.self),
          ObjectIdentifier(ProjectAnalyticsFragment.Country.self),
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Country.self)
        ]
      ))
    }
  }

  /// Creator
  ///
  /// Parent Type: `User`
  public struct Creator: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }

    public var id: GraphAPI.ID { __data["id"] }
    /// Projects a user has created.
    public var createdProjects: CreatedProjects? { __data["createdProjects"] }
    /// The user's provided name.
    public var name: String { __data["name"] }
    /// Is user blocked by current user
    public var isBlocked: Bool? { __data["isBlocked"] }
    /// The user's avatar.
    public var imageUrl: String { __data["imageUrl"] }

    public init(
      id: GraphAPI.ID,
      createdProjects: CreatedProjects? = nil,
      name: String,
      isBlocked: Bool? = nil,
      imageUrl: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.User.typename,
          "id": id,
          "createdProjects": createdProjects._fieldData,
          "name": name,
          "isBlocked": isBlocked,
          "imageUrl": imageUrl,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectCardFragment.Creator.self),
          ObjectIdentifier(ProjectAnalyticsFragment.Creator.self),
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Creator.self)
        ]
      ))
    }

    public typealias CreatedProjects = ProjectAnalyticsFragment.Creator.CreatedProjects
  }

  public typealias ProjectTag = ProjectAnalyticsFragment.ProjectTag

  public typealias Rewards = ProjectAnalyticsFragment.Rewards

  /// Video
  ///
  /// Parent Type: `Video`
  public struct Video: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Video }

    public var id: GraphAPI.ID { __data["id"] }
    /// A video's sources (hls, high, base)
    public var videoSources: VideoSources? { __data["videoSources"] }

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
          ObjectIdentifier(ProjectCardFragment.Video.self),
          ObjectIdentifier(ProjectAnalyticsFragment.Video.self),
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Video.self)
        ]
      ))
    }

    public typealias VideoSources = ProjectPamphletMainCellPropertiesFragment.Video.VideoSources
  }

  public typealias Posts = ProjectAnalyticsFragment.Posts

  public typealias Location = ProjectPamphletMainCellPropertiesFragment.Location
}
