// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ProjectStatsFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ProjectStatsFragment on Project { __typename backersCount commentsCount(withReplies: true) currency fxRate fxRateCurrency goal { __typename ...MoneyFragment } pledged { __typename ...MoneyFragment } posts { __typename totalCount } usdExchangeRate }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("backersCount", Int.self),
    .field("commentsCount", Int.self, arguments: ["withReplies": true]),
    .field("currency", GraphQLEnum<GraphAPI.CurrencyCode>.self),
    .field("fxRate", Double.self),
    .field("fxRateCurrency", GraphQLEnum<GraphAPI.CurrencyCode>.self),
    .field("goal", Goal?.self),
    .field("pledged", Pledged.self),
    .field("posts", Posts.self),
    .field("usdExchangeRate", Double?.self),
  ] }

  /// Total backers for the project
  public var backersCount: Int { __data["backersCount"] }
  /// Comment count - defaults to root level comments only
  public var commentsCount: Int { __data["commentsCount"] }
  /// The project's currency code.
  public var currency: GraphQLEnum<GraphAPI.CurrencyCode> { __data["currency"] }
  /// Exchange rate for the current user's currency
  public var fxRate: Double { __data["fxRate"] }
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

  public init(
    backersCount: Int,
    commentsCount: Int,
    currency: GraphQLEnum<GraphAPI.CurrencyCode>,
    fxRate: Double,
    fxRateCurrency: GraphQLEnum<GraphAPI.CurrencyCode>,
    goal: Goal? = nil,
    pledged: Pledged,
    posts: Posts,
    usdExchangeRate: Double? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Project.typename,
        "backersCount": backersCount,
        "commentsCount": commentsCount,
        "currency": currency,
        "fxRate": fxRate,
        "fxRateCurrency": fxRateCurrency,
        "goal": goal._fieldData,
        "pledged": pledged._fieldData,
        "posts": posts._fieldData,
        "usdExchangeRate": usdExchangeRate,
      ],
      fulfilledFragments: [
        ObjectIdentifier(ProjectStatsFragment.self)
      ]
    ))
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
          ObjectIdentifier(ProjectStatsFragment.Goal.self),
          ObjectIdentifier(MoneyFragment.self)
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
          ObjectIdentifier(ProjectStatsFragment.Pledged.self),
          ObjectIdentifier(MoneyFragment.self)
        ]
      ))
    }
  }

  /// Posts
  ///
  /// Parent Type: `PostConnection`
  public struct Posts: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PostConnection }
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
          "__typename": GraphAPI.Objects.PostConnection.typename,
          "totalCount": totalCount,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectStatsFragment.Posts.self)
        ]
      ))
    }
  }
}
