// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  class FetchMySavedProjectsQuery: GraphQLQuery {
    public static let operationName: String = "FetchMySavedProjects"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query FetchMySavedProjects($first: Int = null, $after: String = null, $withStoredCards: Boolean = false) { projects(first: $first, after: $after, starred: true, sort: END_DATE) { __typename nodes { __typename ...ProjectFragment } pageInfo { __typename hasNextPage endCursor hasPreviousPage startCursor } totalCount } }"#,
        fragments: [CategoryFragment.self, CountryFragment.self, LastWaveFragment.self, LocationFragment.self, MoneyFragment.self, PledgeManagerFragment.self, ProjectFragment.self, UserFragment.self, UserStoredCardsFragment.self]
      ))

    public var first: GraphQLNullable<Int>
    public var after: GraphQLNullable<String>
    public var withStoredCards: GraphQLNullable<Bool>

    public init(
      first: GraphQLNullable<Int> = .null,
      after: GraphQLNullable<String> = .null,
      withStoredCards: GraphQLNullable<Bool> = false
    ) {
      self.first = first
      self.after = after
      self.withStoredCards = withStoredCards
    }

    public var __variables: Variables? { [
      "first": first,
      "after": after,
      "withStoredCards": withStoredCards
    ] }

    public struct Data: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("projects", Projects?.self, arguments: [
          "first": .variable("first"),
          "after": .variable("after"),
          "starred": true,
          "sort": "END_DATE"
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
          .field("pageInfo", PageInfo.self),
          .field("totalCount", Int.self),
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }
        /// Information to aid in pagination.
        public var pageInfo: PageInfo { __data["pageInfo"] }
        public var totalCount: Int { __data["totalCount"] }

        /// Projects.Node
        ///
        /// Parent Type: `Project`
        public struct Node: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ProjectFragment.self),
          ] }

          /// Available card types.
          public var availableCardTypes: [GraphQLEnum<GraphAPI.CreditCardTypes>] { __data["availableCardTypes"] }
          /// Total backers for the project
          public var backersCount: Int { __data["backersCount"] }
          /// The project's category.
          public var category: Category? { __data["category"] }
          /// True if the current user can comment (considers restrictions)
          public var canComment: Bool { __data["canComment"] }
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
          /// A short description of the project.
          public var description: String { __data["description"] }
          /// The environmental commitments of the project.
          public var environmentalCommitments: [EnvironmentalCommitment?]? { __data["environmentalCommitments"] }
          public var aiDisclosure: AiDisclosure? { __data["aiDisclosure"] }
          /// List of FAQs of a project
          public var faqs: Faqs? { __data["faqs"] }
          /// The date at which pledge collections will end
          public var finalCollectionDate: GraphAPI.ISO8601DateTime? { __data["finalCollectionDate"] }
          /// Exchange rate for the current user's currency
          public var fxRate: Double { __data["fxRate"] }
          /// The minimum amount to raise for the project to be successful.
          public var goal: Goal? { __data["goal"] }
          /// The project's primary image.
          public var image: Image? { __data["image"] }
          /// Whether a project is enrolled in plot
          public var isPledgeOverTimeAllowed: Bool { __data["isPledgeOverTimeAllowed"] }
          /// Whether or not this is a Kickstarter-featured project.
          public var isProjectWeLove: Bool { __data["isProjectWeLove"] }
          /// Whether or not this is a Project of the Day.
          public var isProjectOfTheDay: Bool? { __data["isProjectOfTheDay"] }
          /// Is the current user watching this project?
          public var isWatched: Bool { __data["isWatched"] }
          /// The project has launched
          public var isLaunched: Bool { __data["isLaunched"] }
          /// Is this project currently accepting post-campaign pledges?
          public var isInPostCampaignPledgingPhase: Bool { __data["isInPostCampaignPledgingPhase"] }
          /// The last checkout_wave, if there is one
          public var lastWave: LastWave? { __data["lastWave"] }
          /// When the project launched
          public var launchedAt: GraphAPI.DateTime? { __data["launchedAt"] }
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
          /// Backer-facing summary of when the incremental charges will occur
          public var pledgeOverTimeCollectionPlanChargeExplanation: String? { __data["pledgeOverTimeCollectionPlanChargeExplanation"] }
          /// Quick summary of the amount of increments pledges will be spread over
          public var pledgeOverTimeCollectionPlanChargedAsNPayments: String? { __data["pledgeOverTimeCollectionPlanChargedAsNPayments"] }
          /// Backer-facing short summary of this project's number of payment increments to split over
          public var pledgeOverTimeCollectionPlanShortPitch: String? { __data["pledgeOverTimeCollectionPlanShortPitch"] }
          /// The minimum pledge amount to be eligible for PLOT, localized to the project currency and backer language
          public var pledgeOverTimeMinimumExplanation: String? { __data["pledgeOverTimeMinimumExplanation"] }
          /// How much money is pledged to the project.
          public var pledged: Pledged { __data["pledged"] }
          /// Is this project configured for post-campaign pledges?
          public var postCampaignPledgingEnabled: Bool { __data["postCampaignPledgingEnabled"] }
          /// Project updates.
          public var posts: Posts? { __data["posts"] }
          /// Whether a project has activated prelaunch.
          public var prelaunchActivated: Bool { __data["prelaunchActivated"] }
          /// The text of the currently applied project notice, empty if there is no notice
          public var projectNotice: String? { __data["projectNotice"] }
          /// URL for redeeming the backing
          public var redemptionPageUrl: String { __data["redemptionPageUrl"] }
          /// Potential hurdles to project completion.
          public var risks: String { __data["risks"] }
          /// Is this project configured so that events should be triggered for Meta's Conversions API?
          public var sendMetaCapiEvents: Bool { __data["sendMetaCapiEvents"] }
          /// The project's unique URL identifier.
          public var slug: String { __data["slug"] }
          /// The project's current state.
          public var state: GraphQLEnum<GraphAPI.ProjectState> { __data["state"] }
          /// The last time a project's state changed, time since epoch
          public var stateChangedAt: GraphAPI.DateTime { __data["stateChangedAt"] }
          /// The story behind the project, parsed for presentation.
          public var story: GraphAPI.HTML { __data["story"] }
          /// Tags project has been tagged with
          public var tags: [Tag?] { __data["tags"] }
          /// A URL to the project's page.
          public var url: String { __data["url"] }
          /// Exchange rate to US Dollars (USD), null for draft projects.
          public var usdExchangeRate: Double? { __data["usdExchangeRate"] }
          /// A project video.
          public var video: Video? { __data["video"] }
          /// Number of watchers a project has.
          public var watchesCount: Int? { __data["watchesCount"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var projectFragment: ProjectFragment { _toFragment() }
          }

          /// Projects.Node.Category
          ///
          /// Parent Type: `Category`
          public struct Category: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Category }

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

            public typealias ParentCategory = CategoryFragment.ParentCategory
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

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var countryFragment: CountryFragment { _toFragment() }
            }
          }

          /// Projects.Node.Creator
          ///
          /// Parent Type: `User`
          public struct Creator: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }

            /// A user's backings.
            public var backings: Backings? { __data["backings"] }
            /// Number of backings for this user.
            public var backingsCount: Int { __data["backingsCount"] }
            /// The user's chosen currency
            public var chosenCurrency: String? { __data["chosenCurrency"] }
            /// Projects a user has created.
            public var createdProjects: CreatedProjects? { __data["createdProjects"] }
            /// A user's email address.
            public var email: String? { __data["email"] }
            /// Whether or not the user has a password.
            public var hasPassword: Bool? { __data["hasPassword"] }
            /// Whether or not a user has unread messages.
            public var hasUnreadMessages: Bool? { __data["hasUnreadMessages"] }
            /// Whether or not a user has unseen activity.
            public var hasUnseenActivity: Bool? { __data["hasUnseenActivity"] }
            public var id: GraphAPI.ID { __data["id"] }
            /// The user's avatar.
            public var imageUrl: String { __data["imageUrl"] }
            /// Whether or not the user has authenticated with Apple.
            public var isAppleConnected: Bool? { __data["isAppleConnected"] }
            /// Is user blocked by current user
            public var isBlocked: Bool? { __data["isBlocked"] }
            /// Whether a user is a creator of any project
            public var isCreator: Bool? { __data["isCreator"] }
            /// Whether a user's email address is deliverable
            public var isDeliverable: Bool? { __data["isDeliverable"] }
            /// Whether or not the user's email is verified.
            public var isEmailVerified: Bool? { __data["isEmailVerified"] }
            /// Whether or not the user is connected to Facebook.
            public var isFacebookConnected: Bool? { __data["isFacebookConnected"] }
            /// Whether or not you are a KSR admin.
            public var isKsrAdmin: Bool? { __data["isKsrAdmin"] }
            /// Whether or not you are following the user.
            public var isFollowing: Bool { __data["isFollowing"] }
            /// Whether or not the user is either Facebook connected or has follows/followings.
            public var isSocializing: Bool? { __data["isSocializing"] }
            /// Where the user is based.
            public var location: Location? { __data["location"] }
            /// The user's provided name.
            public var name: String { __data["name"] }
            /// Does the user to refresh their facebook token?
            public var needsFreshFacebookToken: Bool? { __data["needsFreshFacebookToken"] }
            /// Which newsleters are the users subscribed to
            public var newsletterSubscriptions: NewsletterSubscriptions? { __data["newsletterSubscriptions"] }
            /// All of a user's notifications
            public var notifications: [Notification]? { __data["notifications"] }
            /// Is the user opted out from receiving recommendations
            public var optedOutOfRecommendations: Bool? { __data["optedOutOfRecommendations"] }
            /// Is the user's profile public
            public var showPublicProfile: Bool? { __data["showPublicProfile"] }
            /// Projects a user has saved.
            public var savedProjects: SavedProjects? { __data["savedProjects"] }
            /// Stored Cards
            public var storedCards: StoredCards? { __data["storedCards"] }
            /// This user's survey responses
            public var surveyResponses: SurveyResponses? { __data["surveyResponses"] }
            /// A user's uid
            public var uid: String { __data["uid"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var userFragment: UserFragment { _toFragment() }
            }

            public typealias Backings = UserFragment.Backings

            public typealias CreatedProjects = UserFragment.CreatedProjects

            /// Projects.Node.Creator.Location
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
            }

            public typealias NewsletterSubscriptions = UserFragment.NewsletterSubscriptions

            public typealias Notification = UserFragment.Notification

            public typealias SavedProjects = UserFragment.SavedProjects

            /// Projects.Node.Creator.StoredCards
            ///
            /// Parent Type: `UserCreditCardTypeConnection`
            public struct StoredCards: GraphAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserCreditCardTypeConnection }

              /// A list of nodes.
              public var nodes: [Node?]? { __data["nodes"] }
              public var totalCount: Int { __data["totalCount"] }

              public struct Fragments: FragmentContainer {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public var userStoredCardsFragment: UserStoredCardsFragment { _toFragment() }
              }

              public typealias Node = UserStoredCardsFragment.Node
            }

            public typealias SurveyResponses = UserFragment.SurveyResponses
          }

          public typealias EnvironmentalCommitment = ProjectFragment.EnvironmentalCommitment

          public typealias AiDisclosure = ProjectFragment.AiDisclosure

          public typealias Faqs = ProjectFragment.Faqs

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

          public typealias Image = ProjectFragment.Image

          /// Projects.Node.LastWave
          ///
          /// Parent Type: `CheckoutWave`
          public struct LastWave: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CheckoutWave }

            public var id: GraphAPI.ID { __data["id"] }
            /// Whether the wave is currently active
            public var active: Bool { __data["active"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var lastWaveFragment: LastWaveFragment { _toFragment() }
            }
          }

          /// Projects.Node.Location
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
          }

          /// Projects.Node.PledgeManager
          ///
          /// Parent Type: `PledgeManager`
          public struct PledgeManager: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PledgeManager }

            public var id: GraphAPI.ID { __data["id"] }
            /// Whether the pledge manager accepts new backers or not
            public var acceptsNewBackers: Bool { __data["acceptsNewBackers"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var pledgeManagerFragment: PledgeManagerFragment { _toFragment() }
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

          public typealias Posts = ProjectFragment.Posts

          public typealias Tag = ProjectFragment.Tag

          public typealias Video = ProjectFragment.Video
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
            .field("hasNextPage", Bool.self),
            .field("endCursor", String?.self),
            .field("hasPreviousPage", Bool.self),
            .field("startCursor", String?.self),
          ] }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? { __data["endCursor"] }
          /// When paginating backwards, are there more items?
          public var hasPreviousPage: Bool { __data["hasPreviousPage"] }
          /// When paginating backwards, the cursor to continue.
          public var startCursor: String? { __data["startCursor"] }
        }
      }
    }
  }

}