// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct BackerDashboardProjectCellFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment BackerDashboardProjectCellFragment on Project { __typename projectId: id name projectState: state image { __typename id url(width: 1024) } goal { __typename ...MoneyFragment } pledged { __typename ...MoneyFragment } isLaunched projectPrelaunchActivated: prelaunchActivated deadlineAt projectLaunchedAt: launchedAt isWatched }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", alias: "projectId", GraphAPI.ID.self),
    .field("name", String.self),
    .field("state", alias: "projectState", GraphQLEnum<GraphAPI.ProjectState>.self),
    .field("image", Image?.self),
    .field("goal", Goal?.self),
    .field("pledged", Pledged.self),
    .field("isLaunched", Bool.self),
    .field("prelaunchActivated", alias: "projectPrelaunchActivated", Bool.self),
    .field("deadlineAt", GraphAPI.DateTime?.self),
    .field("launchedAt", alias: "projectLaunchedAt", GraphAPI.DateTime?.self),
    .field("isWatched", Bool.self),
  ] }

  public var projectId: GraphAPI.ID { __data["projectId"] }
  /// The project's name.
  public var name: String { __data["name"] }
  /// The project's current state.
  public var projectState: GraphQLEnum<GraphAPI.ProjectState> { __data["projectState"] }
  /// The project's primary image.
  public var image: Image? { __data["image"] }
  /// The minimum amount to raise for the project to be successful.
  public var goal: Goal? { __data["goal"] }
  /// How much money is pledged to the project.
  public var pledged: Pledged { __data["pledged"] }
  /// The project has launched
  public var isLaunched: Bool { __data["isLaunched"] }
  /// Whether a project has activated prelaunch.
  public var projectPrelaunchActivated: Bool { __data["projectPrelaunchActivated"] }
  /// When is the project scheduled to end?
  public var deadlineAt: GraphAPI.DateTime? { __data["deadlineAt"] }
  /// When the project launched
  public var projectLaunchedAt: GraphAPI.DateTime? { __data["projectLaunchedAt"] }
  /// Is the current user watching this project?
  public var isWatched: Bool { __data["isWatched"] }

  public init(
    projectId: GraphAPI.ID,
    name: String,
    projectState: GraphQLEnum<GraphAPI.ProjectState>,
    image: Image? = nil,
    goal: Goal? = nil,
    pledged: Pledged,
    isLaunched: Bool,
    projectPrelaunchActivated: Bool,
    deadlineAt: GraphAPI.DateTime? = nil,
    projectLaunchedAt: GraphAPI.DateTime? = nil,
    isWatched: Bool
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Project.typename,
        "projectId": projectId,
        "name": name,
        "projectState": projectState,
        "image": image._fieldData,
        "goal": goal._fieldData,
        "pledged": pledged._fieldData,
        "isLaunched": isLaunched,
        "projectPrelaunchActivated": projectPrelaunchActivated,
        "deadlineAt": deadlineAt,
        "projectLaunchedAt": projectLaunchedAt,
        "isWatched": isWatched,
      ],
      fulfilledFragments: [
        ObjectIdentifier(BackerDashboardProjectCellFragment.self)
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
          ObjectIdentifier(BackerDashboardProjectCellFragment.Image.self)
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
          ObjectIdentifier(BackerDashboardProjectCellFragment.Goal.self),
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
          ObjectIdentifier(BackerDashboardProjectCellFragment.Pledged.self),
          ObjectIdentifier(MoneyFragment.self)
        ]
      ))
    }
  }
}
