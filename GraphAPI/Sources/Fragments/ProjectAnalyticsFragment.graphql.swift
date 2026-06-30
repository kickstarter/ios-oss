// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ProjectAnalyticsFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ProjectAnalyticsFragment on Project { __typename backersCount category { __typename analyticsName parentCategory { __typename analyticsName id } } commentsCount(withReplies: true) country { __typename code } creator { __typename id createdProjects { __typename totalCount } } currency deadlineAt launchedAt pid name isInPostCampaignPledgingPhase isWatched percentFunded isPrelaunchActivated: prelaunchActivated postCampaignPledgingEnabled state pledged { __typename amount } fxRate usdExchangeRate goal { __typename amount } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("backersCount", Int.self),
    .field("category", Category?.self),
    .field("commentsCount", Int.self, arguments: ["withReplies": true]),
    .field("country", Country.self),
    .field("creator", Creator?.self),
    .field("currency", GraphQLEnum<GraphAPI.CurrencyCode>.self),
    .field("deadlineAt", GraphAPI.DateTime?.self),
    .field("launchedAt", GraphAPI.DateTime?.self),
    .field("pid", Int.self),
    .field("name", String.self),
    .field("isInPostCampaignPledgingPhase", Bool.self),
    .field("isWatched", Bool.self),
    .field("percentFunded", Int.self),
    .field("prelaunchActivated", alias: "isPrelaunchActivated", Bool.self),
    .field("postCampaignPledgingEnabled", Bool.self),
    .field("state", GraphQLEnum<GraphAPI.ProjectState>.self),
    .field("pledged", Pledged.self),
    .field("fxRate", Double.self),
    .field("usdExchangeRate", Double?.self),
    .field("goal", Goal?.self),
  ] }

  /// Total backers for the project
  public var backersCount: Int { __data["backersCount"] }
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
  /// When is the project scheduled to end?
  public var deadlineAt: GraphAPI.DateTime? { __data["deadlineAt"] }
  /// When the project launched
  public var launchedAt: GraphAPI.DateTime? { __data["launchedAt"] }
  /// The project's pid.
  public var pid: Int { __data["pid"] }
  /// The project's name.
  public var name: String { __data["name"] }
  /// Is this project currently accepting post-campaign pledges?
  public var isInPostCampaignPledgingPhase: Bool { __data["isInPostCampaignPledgingPhase"] }
  /// Is the current user watching this project?
  public var isWatched: Bool { __data["isWatched"] }
  /// What percent the project has towards meeting its funding goal.
  public var percentFunded: Int { __data["percentFunded"] }
  /// Whether a project has activated prelaunch (can return true if project has been launched)
  public var isPrelaunchActivated: Bool { __data["isPrelaunchActivated"] }
  /// Is this project configured for post-campaign pledges?
  public var postCampaignPledgingEnabled: Bool { __data["postCampaignPledgingEnabled"] }
  /// The project's current state in the state machine.
  public var state: GraphQLEnum<GraphAPI.ProjectState> { __data["state"] }
  /// How much money is pledged to the project.
  public var pledged: Pledged { __data["pledged"] }
  /// Exchange rate for the current user's currency
  public var fxRate: Double { __data["fxRate"] }
  /// Exchange rate to US Dollars (USD), null for draft projects.
  public var usdExchangeRate: Double? { __data["usdExchangeRate"] }
  /// The minimum amount to raise for the project to be successful.
  public var goal: Goal? { __data["goal"] }

  public init(
    backersCount: Int,
    category: Category? = nil,
    commentsCount: Int,
    country: Country,
    creator: Creator? = nil,
    currency: GraphQLEnum<GraphAPI.CurrencyCode>,
    deadlineAt: GraphAPI.DateTime? = nil,
    launchedAt: GraphAPI.DateTime? = nil,
    pid: Int,
    name: String,
    isInPostCampaignPledgingPhase: Bool,
    isWatched: Bool,
    percentFunded: Int,
    isPrelaunchActivated: Bool,
    postCampaignPledgingEnabled: Bool,
    state: GraphQLEnum<GraphAPI.ProjectState>,
    pledged: Pledged,
    fxRate: Double,
    usdExchangeRate: Double? = nil,
    goal: Goal? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Project.typename,
        "backersCount": backersCount,
        "category": category._fieldData,
        "commentsCount": commentsCount,
        "country": country._fieldData,
        "creator": creator._fieldData,
        "currency": currency,
        "deadlineAt": deadlineAt,
        "launchedAt": launchedAt,
        "pid": pid,
        "name": name,
        "isInPostCampaignPledgingPhase": isInPostCampaignPledgingPhase,
        "isWatched": isWatched,
        "percentFunded": percentFunded,
        "isPrelaunchActivated": isPrelaunchActivated,
        "postCampaignPledgingEnabled": postCampaignPledgingEnabled,
        "state": state,
        "pledged": pledged._fieldData,
        "fxRate": fxRate,
        "usdExchangeRate": usdExchangeRate,
        "goal": goal._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(ProjectAnalyticsFragment.self)
      ]
    ))
  }

  /// Category
  ///
  /// Parent Type: `Category`
  public struct Category: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Category }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("analyticsName", String.self),
      .field("parentCategory", ParentCategory?.self),
    ] }

    /// Category name in English for analytics use.
    public var analyticsName: String { __data["analyticsName"] }
    /// Category parent
    public var parentCategory: ParentCategory? { __data["parentCategory"] }

    public init(
      analyticsName: String,
      parentCategory: ParentCategory? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Category.typename,
          "analyticsName": analyticsName,
          "parentCategory": parentCategory._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectAnalyticsFragment.Category.self)
        ]
      ))
    }

    /// Category.ParentCategory
    ///
    /// Parent Type: `Category`
    public struct ParentCategory: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Category }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("analyticsName", String.self),
        .field("id", GraphAPI.ID.self),
      ] }

      /// Category name in English for analytics use.
      public var analyticsName: String { __data["analyticsName"] }
      public var id: GraphAPI.ID { __data["id"] }

      public init(
        analyticsName: String,
        id: GraphAPI.ID
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Category.typename,
            "analyticsName": analyticsName,
            "id": id,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ProjectAnalyticsFragment.Category.ParentCategory.self)
          ]
        ))
      }
    }
  }

  /// Country
  ///
  /// Parent Type: `Country`
  public struct Country: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Country }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("code", GraphQLEnum<GraphAPI.CountryCode>.self),
    ] }

    /// ISO ALPHA-2 code.
    public var code: GraphQLEnum<GraphAPI.CountryCode> { __data["code"] }

    public init(
      code: GraphQLEnum<GraphAPI.CountryCode>
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Country.typename,
          "code": code,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectAnalyticsFragment.Country.self)
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
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", GraphAPI.ID.self),
      .field("createdProjects", CreatedProjects?.self),
    ] }

    public var id: GraphAPI.ID { __data["id"] }
    /// Projects a user has created.
    public var createdProjects: CreatedProjects? { __data["createdProjects"] }

    public init(
      id: GraphAPI.ID,
      createdProjects: CreatedProjects? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.User.typename,
          "id": id,
          "createdProjects": createdProjects._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectAnalyticsFragment.Creator.self)
        ]
      ))
    }

    /// Creator.CreatedProjects
    ///
    /// Parent Type: `UserCreatedProjectsConnection`
    public struct CreatedProjects: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserCreatedProjectsConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("totalCount", Int.self),
      ] }

      public var totalCount: Int { __data["totalCount"] }

      public init(
        totalCount: Int
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.UserCreatedProjectsConnection.typename,
            "totalCount": totalCount,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ProjectAnalyticsFragment.Creator.CreatedProjects.self)
          ]
        ))
      }
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
      .field("amount", String?.self),
    ] }

    /// Floating-point numeric value of monetary amount represented as a string
    public var amount: String? { __data["amount"] }

    public init(
      amount: String? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Money.typename,
          "amount": amount,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectAnalyticsFragment.Pledged.self)
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
      .field("amount", String?.self),
    ] }

    /// Floating-point numeric value of monetary amount represented as a string
    public var amount: String? { __data["amount"] }

    public init(
      amount: String? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Money.typename,
          "amount": amount,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectAnalyticsFragment.Goal.self)
        ]
      ))
    }
  }
}
