// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  struct PPOCardFragment: GraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment PPOCardFragment on PledgeProjectOverviewItem { __typename backing { __typename ...PPOBackingFragment } tierType flags { __typename icon message type } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PledgeProjectOverviewItem }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("backing", Backing?.self),
      .field("tierType", String?.self),
      .field("flags", [Flag]?.self),
    ] }

    /// backing details
    public var backing: Backing? { __data["backing"] }
    /// tier type
    public var tierType: String? { __data["tierType"] }
    /// tags
    public var flags: [Flag]? { __data["flags"] }

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
    }
  }

}