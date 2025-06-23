// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  class SearchQuery: GraphQLQuery {
    public static let operationName: String = "Search"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Search($term: String, $sort: ProjectSort, $categoryId: String, $state: PublicProjectState, $raised: RaisedBuckets, $locationId: ID, $first: Int, $cursor: String) { projects( term: $term sort: $sort categoryId: $categoryId state: $state raised: $raised locationId: $locationId after: $cursor first: $first ) { __typename nodes { __typename ...BackerDashboardProjectCellFragment ...ProjectAnalyticsFragment ...ProjectCardFragment } totalCount pageInfo { __typename endCursor hasNextPage } } }"#,
        fragments: [BackerDashboardProjectCellFragment.self, MoneyFragment.self, ProjectAnalyticsFragment.self, ProjectCardFragment.self, ProjectPamphletMainCellPropertiesFragment.self]
      ))

    public var term: GraphQLNullable<String>
    public var sort: GraphQLNullable<GraphQLEnum<ProjectSort>>
    public var categoryId: GraphQLNullable<String>
    public var state: GraphQLNullable<GraphQLEnum<PublicProjectState>>
    public var raised: GraphQLNullable<GraphQLEnum<RaisedBuckets>>
    public var locationId: GraphQLNullable<ID>
    public var first: GraphQLNullable<Int>
    public var cursor: GraphQLNullable<String>

    public init(
      term: GraphQLNullable<String>,
      sort: GraphQLNullable<GraphQLEnum<ProjectSort>>,
      categoryId: GraphQLNullable<String>,
      state: GraphQLNullable<GraphQLEnum<PublicProjectState>>,
      raised: GraphQLNullable<GraphQLEnum<RaisedBuckets>>,
      locationId: GraphQLNullable<ID>,
      first: GraphQLNullable<Int>,
      cursor: GraphQLNullable<String>
    ) {
      self.term = term
      self.sort = sort
      self.categoryId = categoryId
      self.state = state
      self.raised = raised
      self.locationId = locationId
      self.first = first
      self.cursor = cursor
    }

    public var __variables: Variables? { [
      "term": term,
      "sort": sort,
      "categoryId": categoryId,
      "state": state,
      "raised": raised,
      "locationId": locationId,
      "first": first,
      "cursor": cursor
    ] }

    public struct Data: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("projects", Projects?.self, arguments: [
          "term": .variable("term"),
          "sort": .variable("sort"),
          "categoryId": .variable("categoryId"),
          "state": .variable("state"),
          "raised": .variable("raised"),
          "locationId": .variable("locationId"),
          "after": .variable("cursor"),
          "first": .variable("first")
        ]),
      ] }

      /// Get some projects
      public var projects: Projects? { __data["projects"] }

      /// Projects
      ///
      /// Parent Type: `ProjectsConnectionWithTotalCount`
      public struct Projects: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ProjectsConnectionWithTotalCount }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
          .field("totalCount", Int.self),
          .field("pageInfo", PageInfo.self),
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }
        public var totalCount: Int { __data["totalCount"] }
        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }

        /// Projects.Node
        ///
        /// Parent Type: `Project`
        public struct Node: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(BackerDashboardProjectCellFragment.self),
            .fragment(ProjectAnalyticsFragment.self),
            .fragment(ProjectCardFragment.self),
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
          /// When the project launched
          public var launchedAt: GraphAPI.DateTime? { __data["launchedAt"] }
          /// The project's pid.
          public var pid: Int { __data["pid"] }
          /// Is this project currently accepting post-campaign pledges?
          public var isInPostCampaignPledgingPhase: Bool { __data["isInPostCampaignPledgingPhase"] }
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
          /// Exchange rate for the current user's currency
          public var fxRate: Double { __data["fxRate"] }
          /// Exchange rate to US Dollars (USD), null for draft projects.
          public var usdExchangeRate: Double? { __data["usdExchangeRate"] }
          /// Project updates.
          public var posts: Posts? { __data["posts"] }
          /// Whether a project has activated prelaunch.
          public var prelaunchActivated: Bool { __data["prelaunchActivated"] }
          /// A URL to the project's page.
          public var url: String { __data["url"] }
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

            public var backerDashboardProjectCellFragment: BackerDashboardProjectCellFragment { _toFragment() }
            public var projectAnalyticsFragment: ProjectAnalyticsFragment { _toFragment() }
            public var projectCardFragment: ProjectCardFragment { _toFragment() }
            public var projectPamphletMainCellPropertiesFragment: ProjectPamphletMainCellPropertiesFragment { _toFragment() }
          }

          /// Projects.Node.Image
          ///
          /// Parent Type: `Photo`
          public struct Image: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Photo }

            public var id: GraphAPI.ID { __data["id"] }
            /// URL of the photo
            public var url: String { __data["url"] }
          }

          /// Projects.Node.Goal
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
          }

          /// Projects.Node.Pledged
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
          }

          public typealias AddOns = ProjectAnalyticsFragment.AddOns

          /// Projects.Node.Backing
          ///
          /// Parent Type: `Backing`
          public struct Backing: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Backing }

            public var id: GraphAPI.ID { __data["id"] }
          }

          /// Projects.Node.Category
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

            public typealias ParentCategory = ProjectAnalyticsFragment.Category.ParentCategory
          }

          /// Projects.Node.Country
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
          }

          /// Projects.Node.Creator
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

            public typealias CreatedProjects = ProjectAnalyticsFragment.Creator.CreatedProjects
          }

          public typealias ProjectTag = ProjectAnalyticsFragment.ProjectTag

          public typealias Rewards = ProjectAnalyticsFragment.Rewards

          /// Projects.Node.Video
          ///
          /// Parent Type: `Video`
          public struct Video: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Video }

            public var id: GraphAPI.ID { __data["id"] }
            /// A video's sources (hls, high, base)
            public var videoSources: VideoSources? { __data["videoSources"] }

            public typealias VideoSources = ProjectPamphletMainCellPropertiesFragment.Video.VideoSources
          }

          public typealias Posts = ProjectAnalyticsFragment.Posts

          public typealias Location = ProjectPamphletMainCellPropertiesFragment.Location
        }

        /// Projects.PageInfo
        ///
        /// Parent Type: `PageInfo`
        public struct PageInfo: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PageInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("endCursor", String?.self),
            .field("hasNextPage", Bool.self),
          ] }

          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
        }
      }
    }
  }

}