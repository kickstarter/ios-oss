// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ProjectPamphletMainCellPropertiesFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ProjectPamphletMainCellPropertiesFragment on Project { __typename pid name projectDescription: description creator { __typename id name isBlocked imageUrl(width: 200) } state stateChangedAt image { __typename url(width: 1024) } prelaunchActivated backing { __typename id } backersCount percentFunded goal { __typename ...MoneyFragment } pledged { __typename ...MoneyFragment } currency fxRate usdExchangeRate projectUsdExchangeRate category { __typename name } location { __typename displayableName } deadlineAt launchedAt country { __typename code name } risks video { __typename videoSources { __typename hls { __typename src } high { __typename src } } } url }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("pid", Int.self),
    .field("name", String.self),
    .field("description", alias: "projectDescription", String.self),
    .field("creator", Creator?.self),
    .field("state", GraphQLEnum<GraphAPI.ProjectState>.self),
    .field("stateChangedAt", GraphAPI.DateTime.self),
    .field("image", Image?.self),
    .field("prelaunchActivated", Bool.self),
    .field("backing", Backing?.self),
    .field("backersCount", Int.self),
    .field("percentFunded", Int.self),
    .field("goal", Goal?.self),
    .field("pledged", Pledged.self),
    .field("currency", GraphQLEnum<GraphAPI.CurrencyCode>.self),
    .field("fxRate", Double.self),
    .field("usdExchangeRate", Double?.self),
    .field("projectUsdExchangeRate", Double.self),
    .field("category", Category?.self),
    .field("location", Location?.self),
    .field("deadlineAt", GraphAPI.DateTime?.self),
    .field("launchedAt", GraphAPI.DateTime?.self),
    .field("country", Country.self),
    .field("risks", String.self),
    .field("video", Video?.self),
    .field("url", String.self),
  ] }

  /// The project's pid.
  public var pid: Int { __data["pid"] }
  /// The project's name.
  public var name: String { __data["name"] }
  /// A short description of the project.
  public var projectDescription: String { __data["projectDescription"] }
  /// The project's creator.
  public var creator: Creator? { __data["creator"] }
  /// The project's current state.
  public var state: GraphQLEnum<GraphAPI.ProjectState> { __data["state"] }
  /// The last time a project's state changed, time since epoch
  public var stateChangedAt: GraphAPI.DateTime { __data["stateChangedAt"] }
  /// The project's primary image.
  public var image: Image? { __data["image"] }
  /// Whether a project has activated prelaunch.
  public var prelaunchActivated: Bool { __data["prelaunchActivated"] }
  /// The current user's backing of this project.  Does not include inactive backings.
  public var backing: Backing? { __data["backing"] }
  /// Total backers for the project
  public var backersCount: Int { __data["backersCount"] }
  /// What percent the project has towards meeting its funding goal.
  public var percentFunded: Int { __data["percentFunded"] }
  /// The minimum amount to raise for the project to be successful.
  public var goal: Goal? { __data["goal"] }
  /// How much money is pledged to the project.
  public var pledged: Pledged { __data["pledged"] }
  /// The project's currency code.
  public var currency: GraphQLEnum<GraphAPI.CurrencyCode> { __data["currency"] }
  /// Exchange rate for the current user's currency
  public var fxRate: Double { __data["fxRate"] }
  /// Exchange rate to US Dollars (USD), null for draft projects.
  public var usdExchangeRate: Double? { __data["usdExchangeRate"] }
  /// Exchange rate to US Dollars (USD) for the project's currency
  public var projectUsdExchangeRate: Double { __data["projectUsdExchangeRate"] }
  /// The project's category.
  public var category: Category? { __data["category"] }
  /// Where the project is based.
  public var location: Location? { __data["location"] }
  /// When is the project scheduled to end?
  public var deadlineAt: GraphAPI.DateTime? { __data["deadlineAt"] }
  /// When the project launched
  public var launchedAt: GraphAPI.DateTime? { __data["launchedAt"] }
  /// The project's country
  public var country: Country { __data["country"] }
  /// Potential hurdles to project completion.
  public var risks: String { __data["risks"] }
  /// A project video.
  public var video: Video? { __data["video"] }
  /// A URL to the project's page.
  public var url: String { __data["url"] }

  public init(
    pid: Int,
    name: String,
    projectDescription: String,
    creator: Creator? = nil,
    state: GraphQLEnum<GraphAPI.ProjectState>,
    stateChangedAt: GraphAPI.DateTime,
    image: Image? = nil,
    prelaunchActivated: Bool,
    backing: Backing? = nil,
    backersCount: Int,
    percentFunded: Int,
    goal: Goal? = nil,
    pledged: Pledged,
    currency: GraphQLEnum<GraphAPI.CurrencyCode>,
    fxRate: Double,
    usdExchangeRate: Double? = nil,
    projectUsdExchangeRate: Double,
    category: Category? = nil,
    location: Location? = nil,
    deadlineAt: GraphAPI.DateTime? = nil,
    launchedAt: GraphAPI.DateTime? = nil,
    country: Country,
    risks: String,
    video: Video? = nil,
    url: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Project.typename,
        "pid": pid,
        "name": name,
        "projectDescription": projectDescription,
        "creator": creator._fieldData,
        "state": state,
        "stateChangedAt": stateChangedAt,
        "image": image._fieldData,
        "prelaunchActivated": prelaunchActivated,
        "backing": backing._fieldData,
        "backersCount": backersCount,
        "percentFunded": percentFunded,
        "goal": goal._fieldData,
        "pledged": pledged._fieldData,
        "currency": currency,
        "fxRate": fxRate,
        "usdExchangeRate": usdExchangeRate,
        "projectUsdExchangeRate": projectUsdExchangeRate,
        "category": category._fieldData,
        "location": location._fieldData,
        "deadlineAt": deadlineAt,
        "launchedAt": launchedAt,
        "country": country._fieldData,
        "risks": risks,
        "video": video._fieldData,
        "url": url,
      ],
      fulfilledFragments: [
        ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.self)
      ]
    ))
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
      .field("name", String.self),
      .field("isBlocked", Bool?.self),
      .field("imageUrl", String.self, arguments: ["width": 200]),
    ] }

    public var id: GraphAPI.ID { __data["id"] }
    /// The user's provided name.
    public var name: String { __data["name"] }
    /// Is user blocked by current user
    public var isBlocked: Bool? { __data["isBlocked"] }
    /// The user's avatar.
    public var imageUrl: String { __data["imageUrl"] }

    public init(
      id: GraphAPI.ID,
      name: String,
      isBlocked: Bool? = nil,
      imageUrl: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.User.typename,
          "id": id,
          "name": name,
          "isBlocked": isBlocked,
          "imageUrl": imageUrl,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Creator.self)
        ]
      ))
    }
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
      .field("url", String.self, arguments: ["width": 1024]),
    ] }

    /// URL of the photo
    public var url: String { __data["url"] }

    public init(
      url: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Photo.typename,
          "url": url,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Image.self)
        ]
      ))
    }
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
      .field("id", GraphAPI.ID.self),
    ] }

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
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Backing.self)
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
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Goal.self),
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
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Pledged.self),
          ObjectIdentifier(MoneyFragment.self)
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
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("name", String.self),
    ] }

    /// Category name.
    public var name: String { __data["name"] }

    public init(
      name: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Category.typename,
          "name": name,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Category.self)
        ]
      ))
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
      .field("displayableName", String.self),
    ] }

    /// The displayable name. It includes the state code for US cities. ex: 'Seattle, WA'
    public var displayableName: String { __data["displayableName"] }

    public init(
      displayableName: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Location.typename,
          "displayableName": displayableName,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Location.self)
        ]
      ))
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
      .field("name", String.self),
    ] }

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
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Country.self)
        ]
      ))
    }
  }

  /// Video
  ///
  /// Parent Type: `Video`
  public struct Video: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Video }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("videoSources", VideoSources?.self),
    ] }

    /// A video's sources (hls, high, base)
    public var videoSources: VideoSources? { __data["videoSources"] }

    public init(
      videoSources: VideoSources? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Video.typename,
          "videoSources": videoSources._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Video.self)
        ]
      ))
    }

    /// Video.VideoSources
    ///
    /// Parent Type: `VideoSources`
    public struct VideoSources: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.VideoSources }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("hls", Hls?.self),
        .field("high", High?.self),
      ] }

      public var hls: Hls? { __data["hls"] }
      public var high: High? { __data["high"] }

      public init(
        hls: Hls? = nil,
        high: High? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.VideoSources.typename,
            "hls": hls._fieldData,
            "high": high._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Video.VideoSources.self)
          ]
        ))
      }

      /// Video.VideoSources.Hls
      ///
      /// Parent Type: `VideoSourceInfo`
      public struct Hls: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.VideoSourceInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("src", String?.self),
        ] }

        public var src: String? { __data["src"] }

        public init(
          src: String? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.VideoSourceInfo.typename,
              "src": src,
            ],
            fulfilledFragments: [
              ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Video.VideoSources.Hls.self)
            ]
          ))
        }
      }

      /// Video.VideoSources.High
      ///
      /// Parent Type: `VideoSourceInfo`
      public struct High: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.VideoSourceInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("src", String?.self),
        ] }

        public var src: String? { __data["src"] }

        public init(
          src: String? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.VideoSourceInfo.typename,
              "src": src,
            ],
            fulfilledFragments: [
              ObjectIdentifier(ProjectPamphletMainCellPropertiesFragment.Video.VideoSources.High.self)
            ]
          ))
        }
      }
    }
  }
}
