// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  class FetchSimilarProjectsQuery: GraphQLQuery {
    public static let operationName: String = "FetchSimilarProjects"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query FetchSimilarProjects($projectID: String!) { projects(recommended: true, first: 4, similarToPid: $projectID, state: LIVE) { __typename nodes { __typename ...ProjectCardFragment } } }"#,
        fragments: [MoneyFragment.self, ProjectAnalyticsFragment.self, ProjectCardFragment.self, ProjectPamphletMainCellPropertiesFragment.self]
      ))

    public var projectID: String

    public init(projectID: String) {
      self.projectID = projectID
    }

    public var __variables: Variables? { ["projectID": projectID] }

    public struct Data: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("projects", Projects?.self, arguments: [
          "recommended": true,
          "first": 4,
          "similarToPid": .variable("projectID"),
          "state": "LIVE"
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
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        /// Projects.Node
        ///
        /// Parent Type: `Project`
        public struct Node: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ProjectCardFragment.self),
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

            public var projectCardFragment: ProjectCardFragment { _toFragment() }
            public var projectAnalyticsFragment: ProjectAnalyticsFragment { _toFragment() }
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
      }
    }
  }

}