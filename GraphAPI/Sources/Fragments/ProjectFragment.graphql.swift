// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ProjectFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ProjectFragment on Project { __typename availableCardTypes category { __typename ...CategoryFragment } canComment country { __typename ...CountryFragment } creator { __typename ...PublicUserFragment } description ...ExtendedProjectPropertiesFragment image { __typename id url(width: 1024) } isProjectWeLove isWatched isLaunched isInPostCampaignPledgingPhase lastWave { __typename ...LastWaveFragment } location { __typename ...LocationFragment } maxPledge minPledge name ...NoRewardRewardFragment pid pledgeManager { __typename ...PledgeManagerFragment } ...PledgeOverTimeFragment postCampaignPledgingEnabled prelaunchActivated ...ProjectStatsFragment ...ProjectDatesFragment redemptionPageUrl sendMetaCapiEvents slug state tags(scope: DISCOVER) { __typename name } url video { __typename ...ProjectVideoFragment } watchesCount }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("availableCardTypes", [GraphQLEnum<GraphAPI.CreditCardTypes>].self),
    .field("category", Category?.self),
    .field("canComment", Bool.self),
    .field("country", Country.self),
    .field("creator", Creator?.self),
    .field("description", String.self),
    .field("image", Image?.self),
    .field("isProjectWeLove", Bool.self),
    .field("isWatched", Bool.self),
    .field("isLaunched", Bool.self),
    .field("isInPostCampaignPledgingPhase", Bool.self),
    .field("lastWave", LastWave?.self),
    .field("location", Location?.self),
    .field("maxPledge", Int.self),
    .field("minPledge", Int.self),
    .field("name", String.self),
    .field("pid", Int.self),
    .field("pledgeManager", PledgeManager?.self),
    .field("postCampaignPledgingEnabled", Bool.self),
    .field("prelaunchActivated", Bool.self),
    .field("redemptionPageUrl", String.self),
    .field("sendMetaCapiEvents", Bool.self),
    .field("slug", String.self),
    .field("state", GraphQLEnum<GraphAPI.ProjectState>.self),
    .field("tags", [Tag?].self, arguments: ["scope": "DISCOVER"]),
    .field("url", String.self),
    .field("video", Video?.self),
    .field("watchesCount", Int?.self),
    .fragment(ExtendedProjectPropertiesFragment.self),
    .fragment(NoRewardRewardFragment.self),
    .fragment(PledgeOverTimeFragment.self),
    .fragment(ProjectStatsFragment.self),
    .fragment(ProjectDatesFragment.self),
  ] }

  /// Available card types.
  public var availableCardTypes: [GraphQLEnum<GraphAPI.CreditCardTypes>] { __data["availableCardTypes"] }
  /// The project's category.
  public var category: Category? { __data["category"] }
  /// True if the current user can comment (considers restrictions)
  public var canComment: Bool { __data["canComment"] }
  /// The project's country
  public var country: Country { __data["country"] }
  /// The project's creator.
  public var creator: Creator? { __data["creator"] }
  /// A short description of the project.
  public var description: String { __data["description"] }
  /// The project's primary image.
  public var image: Image? { __data["image"] }
  /// Whether or not this is a Kickstarter-featured project.
  public var isProjectWeLove: Bool { __data["isProjectWeLove"] }
  /// Is the current user watching this project?
  public var isWatched: Bool { __data["isWatched"] }
  /// The project has launched
  public var isLaunched: Bool { __data["isLaunched"] }
  /// Is this project currently accepting post-campaign pledges?
  public var isInPostCampaignPledgingPhase: Bool { __data["isInPostCampaignPledgingPhase"] }
  /// The last checkout_wave, if there is one
  public var lastWave: LastWave? { __data["lastWave"] }
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
  /// Is this project configured for post-campaign pledges?
  public var postCampaignPledgingEnabled: Bool { __data["postCampaignPledgingEnabled"] }
  /// Whether a project has activated prelaunch (can return true if project has been launched)
  public var prelaunchActivated: Bool { __data["prelaunchActivated"] }
  /// URL for redeeming the backing
  public var redemptionPageUrl: String { __data["redemptionPageUrl"] }
  /// Is this project configured so that events should be triggered for Meta's Conversions API?
  public var sendMetaCapiEvents: Bool { __data["sendMetaCapiEvents"] }
  /// The project's unique URL identifier.
  public var slug: String { __data["slug"] }
  /// The project's current state in the state machine.
  public var state: GraphQLEnum<GraphAPI.ProjectState> { __data["state"] }
  /// Tags project has been tagged with
  public var tags: [Tag?] { __data["tags"] }
  /// A URL to the project's page.
  public var url: String { __data["url"] }
  /// A project video.
  public var video: Video? { __data["video"] }
  /// Number of watchers a project has.
  public var watchesCount: Int? { __data["watchesCount"] }
  public var aiDisclosure: AiDisclosure? { __data["aiDisclosure"] }
  /// The environmental commitments of the project.
  public var environmentalCommitments: [EnvironmentalCommitment?]? { __data["environmentalCommitments"] }
  /// List of FAQs of a project
  public var faqs: Faqs? { __data["faqs"] }
  /// The text of the currently applied project notice, empty if there is no notice
  public var projectNotice: String? { __data["projectNotice"] }
  /// Potential hurdles to project completion.
  public var risks: String { __data["risks"] }
  /// The story behind the project, parsed for presentation.
  public var story: GraphAPI.HTML { __data["story"] }
  /// Exchange rate for the current user's currency
  public var fxRate: Double { __data["fxRate"] }
  /// Whether a project is enrolled in plot
  public var isPledgeOverTimeAllowed: Bool { __data["isPledgeOverTimeAllowed"] }
  /// Backer-facing summary of when the incremental charges will occur
  public var pledgeOverTimeCollectionPlanChargeExplanation: String? { __data["pledgeOverTimeCollectionPlanChargeExplanation"] }
  /// Quick summary of the amount of increments pledges will be spread over
  public var pledgeOverTimeCollectionPlanChargedAsNPayments: String? { __data["pledgeOverTimeCollectionPlanChargedAsNPayments"] }
  /// Backer-facing short summary of this project's number of payment increments to split over
  public var pledgeOverTimeCollectionPlanShortPitch: String? { __data["pledgeOverTimeCollectionPlanShortPitch"] }
  /// The minimum pledge amount to be eligible for PLOT, localized to the project currency and backer language
  public var pledgeOverTimeMinimumExplanation: String? { __data["pledgeOverTimeMinimumExplanation"] }
  /// Total backers for the project
  public var backersCount: Int { __data["backersCount"] }
  /// Comment count - defaults to root level comments only
  public var commentsCount: Int { __data["commentsCount"] }
  /// The project's currency code.
  public var currency: GraphQLEnum<GraphAPI.CurrencyCode> { __data["currency"] }
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
  /// Whether or not this is a Project of the Day.
  public var isProjectOfTheDay: Bool? { __data["isProjectOfTheDay"] }
  /// When is the project scheduled to end?
  public var deadlineAt: GraphAPI.DateTime? { __data["deadlineAt"] }
  /// The date at which pledge collections will end
  public var finalCollectionDate: GraphAPI.ISO8601DateTime? { __data["finalCollectionDate"] }
  /// When the project launched
  public var launchedAt: GraphAPI.DateTime? { __data["launchedAt"] }
  /// The last time a project's state changed, time since epoch
  public var stateChangedAt: GraphAPI.DateTime { __data["stateChangedAt"] }

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public var extendedProjectPropertiesFragment: ExtendedProjectPropertiesFragment { _toFragment() }
    public var noRewardRewardFragment: NoRewardRewardFragment { _toFragment() }
    public var pledgeOverTimeFragment: PledgeOverTimeFragment { _toFragment() }
    public var projectStatsFragment: ProjectStatsFragment { _toFragment() }
    public var projectDatesFragment: ProjectDatesFragment { _toFragment() }
  }

  public init(
    availableCardTypes: [GraphQLEnum<GraphAPI.CreditCardTypes>],
    category: Category? = nil,
    canComment: Bool,
    country: Country,
    creator: Creator? = nil,
    description: String,
    image: Image? = nil,
    isProjectWeLove: Bool,
    isWatched: Bool,
    isLaunched: Bool,
    isInPostCampaignPledgingPhase: Bool,
    lastWave: LastWave? = nil,
    location: Location? = nil,
    maxPledge: Int,
    minPledge: Int,
    name: String,
    pid: Int,
    pledgeManager: PledgeManager? = nil,
    postCampaignPledgingEnabled: Bool,
    prelaunchActivated: Bool,
    redemptionPageUrl: String,
    sendMetaCapiEvents: Bool,
    slug: String,
    state: GraphQLEnum<GraphAPI.ProjectState>,
    tags: [Tag?],
    url: String,
    video: Video? = nil,
    watchesCount: Int? = nil,
    aiDisclosure: AiDisclosure? = nil,
    environmentalCommitments: [EnvironmentalCommitment?]? = nil,
    faqs: Faqs? = nil,
    projectNotice: String? = nil,
    risks: String,
    story: GraphAPI.HTML,
    fxRate: Double,
    isPledgeOverTimeAllowed: Bool,
    pledgeOverTimeCollectionPlanChargeExplanation: String? = nil,
    pledgeOverTimeCollectionPlanChargedAsNPayments: String? = nil,
    pledgeOverTimeCollectionPlanShortPitch: String? = nil,
    pledgeOverTimeMinimumExplanation: String? = nil,
    backersCount: Int,
    commentsCount: Int,
    currency: GraphQLEnum<GraphAPI.CurrencyCode>,
    fxRateCurrency: GraphQLEnum<GraphAPI.CurrencyCode>,
    goal: Goal? = nil,
    pledged: Pledged,
    posts: Posts,
    usdExchangeRate: Double? = nil,
    isProjectOfTheDay: Bool? = nil,
    deadlineAt: GraphAPI.DateTime? = nil,
    finalCollectionDate: GraphAPI.ISO8601DateTime? = nil,
    launchedAt: GraphAPI.DateTime? = nil,
    stateChangedAt: GraphAPI.DateTime
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Project.typename,
        "availableCardTypes": availableCardTypes,
        "category": category._fieldData,
        "canComment": canComment,
        "country": country._fieldData,
        "creator": creator._fieldData,
        "description": description,
        "image": image._fieldData,
        "isProjectWeLove": isProjectWeLove,
        "isWatched": isWatched,
        "isLaunched": isLaunched,
        "isInPostCampaignPledgingPhase": isInPostCampaignPledgingPhase,
        "lastWave": lastWave._fieldData,
        "location": location._fieldData,
        "maxPledge": maxPledge,
        "minPledge": minPledge,
        "name": name,
        "pid": pid,
        "pledgeManager": pledgeManager._fieldData,
        "postCampaignPledgingEnabled": postCampaignPledgingEnabled,
        "prelaunchActivated": prelaunchActivated,
        "redemptionPageUrl": redemptionPageUrl,
        "sendMetaCapiEvents": sendMetaCapiEvents,
        "slug": slug,
        "state": state,
        "tags": tags._fieldData,
        "url": url,
        "video": video._fieldData,
        "watchesCount": watchesCount,
        "aiDisclosure": aiDisclosure._fieldData,
        "environmentalCommitments": environmentalCommitments._fieldData,
        "faqs": faqs._fieldData,
        "projectNotice": projectNotice,
        "risks": risks,
        "story": story,
        "fxRate": fxRate,
        "isPledgeOverTimeAllowed": isPledgeOverTimeAllowed,
        "pledgeOverTimeCollectionPlanChargeExplanation": pledgeOverTimeCollectionPlanChargeExplanation,
        "pledgeOverTimeCollectionPlanChargedAsNPayments": pledgeOverTimeCollectionPlanChargedAsNPayments,
        "pledgeOverTimeCollectionPlanShortPitch": pledgeOverTimeCollectionPlanShortPitch,
        "pledgeOverTimeMinimumExplanation": pledgeOverTimeMinimumExplanation,
        "backersCount": backersCount,
        "commentsCount": commentsCount,
        "currency": currency,
        "fxRateCurrency": fxRateCurrency,
        "goal": goal._fieldData,
        "pledged": pledged._fieldData,
        "posts": posts._fieldData,
        "usdExchangeRate": usdExchangeRate,
        "isProjectOfTheDay": isProjectOfTheDay,
        "deadlineAt": deadlineAt,
        "finalCollectionDate": finalCollectionDate,
        "launchedAt": launchedAt,
        "stateChangedAt": stateChangedAt,
      ],
      fulfilledFragments: [
        ObjectIdentifier(ProjectFragment.self),
        ObjectIdentifier(ExtendedProjectPropertiesFragment.self),
        ObjectIdentifier(NoRewardRewardFragment.self),
        ObjectIdentifier(PledgeOverTimeFragment.self),
        ObjectIdentifier(ProjectStatsFragment.self),
        ObjectIdentifier(ProjectDatesFragment.self)
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
      .fragment(CategoryFragment.self),
    ] }

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
          ObjectIdentifier(ProjectFragment.Category.self),
          ObjectIdentifier(CategoryFragment.self)
        ]
      ))
    }

    public typealias ParentCategory = CategoryFragment.ParentCategory
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
      .fragment(CountryFragment.self),
    ] }

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
          ObjectIdentifier(ProjectFragment.Country.self),
          ObjectIdentifier(CountryFragment.self)
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
      .fragment(PublicUserFragment.self),
    ] }

    public var id: GraphAPI.ID { __data["id"] }
    /// The user's avatar.
    public var imageUrl: String { __data["imageUrl"] }
    /// Is user blocked by current user
    public var isBlocked: Bool? { __data["isBlocked"] }
    /// Whether or not you are following the user.
    public var isFollowing: Bool { __data["isFollowing"] }
    /// Where the user is based.
    public var location: Location? { __data["location"] }
    /// The user's provided name.
    public var name: String { __data["name"] }
    /// Is the user's profile public
    public var showPublicProfile: Bool? { __data["showPublicProfile"] }
    /// A user's uid
    public var uid: String { __data["uid"] }
    /// Number of backings for this user.
    public var backingsCount: Int { __data["backingsCount"] }
    /// Projects a user has created.
    public var createdProjects: CreatedProjects? { __data["createdProjects"] }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var publicUserFragment: PublicUserFragment { _toFragment() }
    }

    public init(
      id: GraphAPI.ID,
      imageUrl: String,
      isBlocked: Bool? = nil,
      isFollowing: Bool,
      location: Location? = nil,
      name: String,
      showPublicProfile: Bool? = nil,
      uid: String,
      backingsCount: Int,
      createdProjects: CreatedProjects? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.User.typename,
          "id": id,
          "imageUrl": imageUrl,
          "isBlocked": isBlocked,
          "isFollowing": isFollowing,
          "location": location._fieldData,
          "name": name,
          "showPublicProfile": showPublicProfile,
          "uid": uid,
          "backingsCount": backingsCount,
          "createdProjects": createdProjects._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectFragment.Creator.self),
          ObjectIdentifier(PublicUserFragment.self)
        ]
      ))
    }

    /// Creator.Location
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
            ObjectIdentifier(ProjectFragment.Creator.Location.self),
            ObjectIdentifier(PublicUserFragment.Location.self),
            ObjectIdentifier(LocationFragment.self)
          ]
        ))
      }
    }

    public typealias CreatedProjects = PublicUserFragment.CreatedProjects
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
          ObjectIdentifier(ProjectFragment.Image.self)
        ]
      ))
    }
  }

  /// LastWave
  ///
  /// Parent Type: `CheckoutWave`
  public struct LastWave: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CheckoutWave }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(LastWaveFragment.self),
    ] }

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
          ObjectIdentifier(ProjectFragment.LastWave.self),
          ObjectIdentifier(LastWaveFragment.self)
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
          ObjectIdentifier(ProjectFragment.Location.self),
          ObjectIdentifier(LocationFragment.self)
        ]
      ))
    }
  }

  /// PledgeManager
  ///
  /// Parent Type: `PledgeManager`
  public struct PledgeManager: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PledgeManager }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(PledgeManagerFragment.self),
    ] }

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
          ObjectIdentifier(ProjectFragment.PledgeManager.self),
          ObjectIdentifier(PledgeManagerFragment.self)
        ]
      ))
    }
  }

  /// Tag
  ///
  /// Parent Type: `Tag`
  public struct Tag: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Tag }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("name", String.self),
    ] }

    /// Tag name.
    public var name: String { __data["name"] }

    public init(
      name: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Tag.typename,
          "name": name,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectFragment.Tag.self)
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
      .fragment(ProjectVideoFragment.self),
    ] }

    public var id: GraphAPI.ID { __data["id"] }
    /// A video's sources (hls, high, base)
    public var videoSources: VideoSources? { __data["videoSources"] }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var projectVideoFragment: ProjectVideoFragment { _toFragment() }
    }

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
          ObjectIdentifier(ProjectFragment.Video.self),
          ObjectIdentifier(ProjectVideoFragment.self)
        ]
      ))
    }

    public typealias VideoSources = ProjectVideoFragment.VideoSources
  }

  public typealias AiDisclosure = ExtendedProjectPropertiesFragment.AiDisclosure

  public typealias EnvironmentalCommitment = ExtendedProjectPropertiesFragment.EnvironmentalCommitment

  public typealias Faqs = ExtendedProjectPropertiesFragment.Faqs

  /// Goal
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
          ObjectIdentifier(ProjectFragment.Goal.self),
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
          ObjectIdentifier(ProjectFragment.Pledged.self),
          ObjectIdentifier(ProjectStatsFragment.Pledged.self),
          ObjectIdentifier(MoneyFragment.self)
        ]
      ))
    }
  }

  public typealias Posts = ProjectStatsFragment.Posts
}
