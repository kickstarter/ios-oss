// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RewardFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RewardFragment on Reward { __typename amount { __typename ...MoneyFragment } backersCount convertedAmount { __typename ...MoneyFragment } allowedAddons { __typename pageInfo { __typename startCursor } } description displayName endsAt estimatedDeliveryOn id isMaxPledge available items { __typename edges { __typename quantity node { __typename id name } } } limit limitPerBacker localReceiptLocation @include(if: $includeLocalPickup) { __typename ...LocationFragment } name pledgeAmount { __typename ...MoneyFragment } latePledgeAmount { __typename ...MoneyFragment } postCampaignPledgingEnabled project { __typename id } remainingQuantity shippingPreference shippingSummary shippingRules @include(if: $includeShippingRules) { __typename ...ShippingRuleFragment } startsAt image { __typename altText url(width: 1024) } audienceData { __typename secret } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Reward }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("amount", Amount.self),
    .field("backersCount", Int?.self),
    .field("convertedAmount", ConvertedAmount.self),
    .field("allowedAddons", AllowedAddons.self),
    .field("description", String.self),
    .field("displayName", String.self),
    .field("endsAt", GraphAPI.DateTime?.self),
    .field("estimatedDeliveryOn", GraphAPI.Date?.self),
    .field("id", GraphAPI.ID.self),
    .field("isMaxPledge", Bool.self),
    .field("available", Bool.self),
    .field("items", Items?.self),
    .field("limit", Int?.self),
    .field("limitPerBacker", Int?.self),
    .field("name", String?.self),
    .field("pledgeAmount", PledgeAmount.self),
    .field("latePledgeAmount", LatePledgeAmount.self),
    .field("postCampaignPledgingEnabled", Bool.self),
    .field("project", Project?.self),
    .field("remainingQuantity", Int?.self),
    .field("shippingPreference", GraphQLEnum<GraphAPI.ShippingPreference>?.self),
    .field("shippingSummary", String?.self),
    .field("startsAt", GraphAPI.DateTime?.self),
    .field("image", Image?.self),
    .field("audienceData", AudienceData.self),
    .include(if: "includeLocalPickup", .field("localReceiptLocation", LocalReceiptLocation?.self)),
    .include(if: "includeShippingRules", .field("shippingRules", [ShippingRule?].self)),
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
        ObjectIdentifier(RewardFragment.self)
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
          ObjectIdentifier(RewardFragment.Amount.self),
          ObjectIdentifier(MoneyFragment.self)
        ]
      ))
    }
  }

  /// ConvertedAmount
  ///
  /// Parent Type: `Money`
  public struct ConvertedAmount: GraphAPI.SelectionSet {
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
          ObjectIdentifier(RewardFragment.ConvertedAmount.self),
          ObjectIdentifier(MoneyFragment.self)
        ]
      ))
    }
  }

  /// AllowedAddons
  ///
  /// Parent Type: `RewardConnection`
  public struct AllowedAddons: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RewardConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("pageInfo", PageInfo.self),
    ] }

    /// Information to aid in pagination.
    public var pageInfo: PageInfo { __data["pageInfo"] }

    public init(
      pageInfo: PageInfo
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RewardConnection.typename,
          "pageInfo": pageInfo._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RewardFragment.AllowedAddons.self)
        ]
      ))
    }

    /// AllowedAddons.PageInfo
    ///
    /// Parent Type: `PageInfo`
    public struct PageInfo: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PageInfo }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("startCursor", String?.self),
      ] }

      /// When paginating backwards, the cursor to continue.
      public var startCursor: String? { __data["startCursor"] }

      public init(
        startCursor: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.PageInfo.typename,
            "startCursor": startCursor,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RewardFragment.AllowedAddons.PageInfo.self)
          ]
        ))
      }
    }
  }

  /// Items
  ///
  /// Parent Type: `RewardItemsConnection`
  public struct Items: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RewardItemsConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("edges", [Edge?]?.self),
    ] }

    /// A list of edges.
    public var edges: [Edge?]? { __data["edges"] }

    public init(
      edges: [Edge?]? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RewardItemsConnection.typename,
          "edges": edges._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RewardFragment.Items.self)
        ]
      ))
    }

    /// Items.Edge
    ///
    /// Parent Type: `RewardItemEdge`
    public struct Edge: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RewardItemEdge }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("quantity", Int.self),
        .field("node", Node?.self),
      ] }

      /// The quantity of an item associated with a reward
      public var quantity: Int { __data["quantity"] }
      /// The item at the end of the edge.
      public var node: Node? { __data["node"] }

      public init(
        quantity: Int,
        node: Node? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.RewardItemEdge.typename,
            "quantity": quantity,
            "node": node._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RewardFragment.Items.Edge.self)
          ]
        ))
      }

      /// Items.Edge.Node
      ///
      /// Parent Type: `RewardItem`
      public struct Node: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RewardItem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GraphAPI.ID.self),
          .field("name", String.self),
        ] }

        public var id: GraphAPI.ID { __data["id"] }
        /// An item name.
        public var name: String { __data["name"] }

        public init(
          id: GraphAPI.ID,
          name: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.RewardItem.typename,
              "id": id,
              "name": name,
            ],
            fulfilledFragments: [
              ObjectIdentifier(RewardFragment.Items.Edge.Node.self)
            ]
          ))
        }
      }
    }
  }

  /// LocalReceiptLocation
  ///
  /// Parent Type: `Location`
  public struct LocalReceiptLocation: GraphAPI.SelectionSet {
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
          ObjectIdentifier(RewardFragment.LocalReceiptLocation.self),
          ObjectIdentifier(LocationFragment.self)
        ]
      ))
    }
  }

  /// PledgeAmount
  ///
  /// Parent Type: `Money`
  public struct PledgeAmount: GraphAPI.SelectionSet {
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
          ObjectIdentifier(RewardFragment.PledgeAmount.self),
          ObjectIdentifier(MoneyFragment.self)
        ]
      ))
    }
  }

  /// LatePledgeAmount
  ///
  /// Parent Type: `Money`
  public struct LatePledgeAmount: GraphAPI.SelectionSet {
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
          ObjectIdentifier(RewardFragment.LatePledgeAmount.self),
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
      .field("id", GraphAPI.ID.self),
    ] }

    public var id: GraphAPI.ID { __data["id"] }

    public init(
      id: GraphAPI.ID
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Project.typename,
          "id": id,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RewardFragment.Project.self)
        ]
      ))
    }
  }

  /// ShippingRule
  ///
  /// Parent Type: `ShippingRule`
  public struct ShippingRule: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ShippingRule }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(ShippingRuleFragment.self),
    ] }

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
          ObjectIdentifier(RewardFragment.ShippingRule.self),
          ObjectIdentifier(ShippingRuleFragment.self)
        ]
      ))
    }

    /// ShippingRule.Cost
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
            ObjectIdentifier(RewardFragment.ShippingRule.Cost.self),
            ObjectIdentifier(ShippingRuleFragment.Cost.self),
            ObjectIdentifier(MoneyFragment.self)
          ]
        ))
      }
    }

    /// ShippingRule.Location
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
            ObjectIdentifier(RewardFragment.ShippingRule.Location.self),
            ObjectIdentifier(ShippingRuleFragment.Location.self),
            ObjectIdentifier(LocationFragment.self)
          ]
        ))
      }
    }

    public typealias EstimatedMin = ShippingRuleFragment.EstimatedMin

    public typealias EstimatedMax = ShippingRuleFragment.EstimatedMax
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
      .field("altText", String.self),
      .field("url", String.self, arguments: ["width": 1024]),
    ] }

    /// Alt text on the image
    public var altText: String { __data["altText"] }
    /// URL of the photo
    public var url: String { __data["url"] }

    public init(
      altText: String,
      url: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Photo.typename,
          "altText": altText,
          "url": url,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RewardFragment.Image.self)
        ]
      ))
    }
  }

  /// AudienceData
  ///
  /// Parent Type: `ResourceAudience`
  public struct AudienceData: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ResourceAudience }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("secret", Bool.self),
    ] }

    /// True if the resource has access restricted by an access rule
    public var secret: Bool { __data["secret"] }

    public init(
      secret: Bool
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.ResourceAudience.typename,
          "secret": secret,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RewardFragment.AudienceData.self)
        ]
      ))
    }
  }
}
