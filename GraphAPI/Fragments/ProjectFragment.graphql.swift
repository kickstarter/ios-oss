// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  struct ProjectFragment: GraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ProjectFragment on Project { __typename availableCardTypes backersCount category { __typename ...CategoryFragment } canComment commentsCount(withReplies: true) country { __typename ...CountryFragment } creator { __typename ...UserFragment } currency deadlineAt description environmentalCommitments { __typename commitmentCategory description id } aiDisclosure { __typename id fundingForAiAttribution fundingForAiConsent fundingForAiOption generatedByAiConsent generatedByAiDetails involvesAi involvesFunding involvesGeneration involvesOther otherAiDetails } faqs { __typename nodes { __typename question answer id createdAt } } finalCollectionDate fxRate goal { __typename ...MoneyFragment } image { __typename id url(width: 1024) } isPledgeOverTimeAllowed isProjectWeLove isProjectOfTheDay isWatched isLaunched isInPostCampaignPledgingPhase lastWave { __typename ...LastWaveFragment } launchedAt location { __typename ...LocationFragment } maxPledge minPledge name pid pledgeManager { __typename ...PledgeManagerFragment } pledgeOverTimeCollectionPlanChargeExplanation pledgeOverTimeCollectionPlanChargedAsNPayments pledgeOverTimeCollectionPlanShortPitch pledgeOverTimeMinimumExplanation pledged { __typename ...MoneyFragment } postCampaignPledgingEnabled posts { __typename totalCount } prelaunchActivated projectNotice redemptionPageUrl risks sendMetaCapiEvents slug state stateChangedAt story tags(scope: DISCOVER) { __typename name } url usdExchangeRate video { __typename id videoSources { __typename high { __typename src } hls { __typename src } } } watchesCount }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("availableCardTypes", [GraphQLEnum<GraphAPI.CreditCardTypes>].self),
      .field("backersCount", Int.self),
      .field("category", Category?.self),
      .field("canComment", Bool.self),
      .field("commentsCount", Int.self, arguments: ["withReplies": true]),
      .field("country", Country.self),
      .field("creator", Creator?.self),
      .field("currency", GraphQLEnum<GraphAPI.CurrencyCode>.self),
      .field("deadlineAt", GraphAPI.DateTime?.self),
      .field("description", String.self),
      .field("environmentalCommitments", [EnvironmentalCommitment?]?.self),
      .field("aiDisclosure", AiDisclosure?.self),
      .field("faqs", Faqs?.self),
      .field("finalCollectionDate", GraphAPI.ISO8601DateTime?.self),
      .field("fxRate", Double.self),
      .field("goal", Goal?.self),
      .field("image", Image?.self),
      .field("isPledgeOverTimeAllowed", Bool.self),
      .field("isProjectWeLove", Bool.self),
      .field("isProjectOfTheDay", Bool?.self),
      .field("isWatched", Bool.self),
      .field("isLaunched", Bool.self),
      .field("isInPostCampaignPledgingPhase", Bool.self),
      .field("lastWave", LastWave?.self),
      .field("launchedAt", GraphAPI.DateTime?.self),
      .field("location", Location?.self),
      .field("maxPledge", Int.self),
      .field("minPledge", Int.self),
      .field("name", String.self),
      .field("pid", Int.self),
      .field("pledgeManager", PledgeManager?.self),
      .field("pledgeOverTimeCollectionPlanChargeExplanation", String?.self),
      .field("pledgeOverTimeCollectionPlanChargedAsNPayments", String?.self),
      .field("pledgeOverTimeCollectionPlanShortPitch", String?.self),
      .field("pledgeOverTimeMinimumExplanation", String?.self),
      .field("pledged", Pledged.self),
      .field("postCampaignPledgingEnabled", Bool.self),
      .field("posts", Posts?.self),
      .field("prelaunchActivated", Bool.self),
      .field("projectNotice", String?.self),
      .field("redemptionPageUrl", String.self),
      .field("risks", String.self),
      .field("sendMetaCapiEvents", Bool.self),
      .field("slug", String.self),
      .field("state", GraphQLEnum<GraphAPI.ProjectState>.self),
      .field("stateChangedAt", GraphAPI.DateTime.self),
      .field("story", GraphAPI.HTML.self),
      .field("tags", [Tag?].self, arguments: ["scope": "DISCOVER"]),
      .field("url", String.self),
      .field("usdExchangeRate", Double?.self),
      .field("video", Video?.self),
      .field("watchesCount", Int?.self),
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
        .fragment(UserFragment.self),
      ] }

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
      }

      public typealias NewsletterSubscriptions = UserFragment.NewsletterSubscriptions

      public typealias Notification = UserFragment.Notification

      public typealias SavedProjects = UserFragment.SavedProjects

      /// Creator.StoredCards
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

    /// EnvironmentalCommitment
    ///
    /// Parent Type: `EnvironmentalCommitment`
    public struct EnvironmentalCommitment: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.EnvironmentalCommitment }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("commitmentCategory", GraphQLEnum<GraphAPI.EnvironmentalCommitmentCategory>.self),
        .field("description", String.self),
        .field("id", GraphAPI.ID.self),
      ] }

      /// The type of environmental commitment
      public var commitmentCategory: GraphQLEnum<GraphAPI.EnvironmentalCommitmentCategory> { __data["commitmentCategory"] }
      /// An environmental commitment description
      public var description: String { __data["description"] }
      public var id: GraphAPI.ID { __data["id"] }
    }

    /// AiDisclosure
    ///
    /// Parent Type: `AiDisclosure`
    public struct AiDisclosure: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.AiDisclosure }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GraphAPI.ID.self),
        .field("fundingForAiAttribution", Bool?.self),
        .field("fundingForAiConsent", Bool?.self),
        .field("fundingForAiOption", Bool?.self),
        .field("generatedByAiConsent", String?.self),
        .field("generatedByAiDetails", String?.self),
        .field("involvesAi", Bool.self),
        .field("involvesFunding", Bool.self),
        .field("involvesGeneration", Bool.self),
        .field("involvesOther", Bool.self),
        .field("otherAiDetails", String?.self),
      ] }

      public var id: GraphAPI.ID { __data["id"] }
      public var fundingForAiAttribution: Bool? { __data["fundingForAiAttribution"] }
      public var fundingForAiConsent: Bool? { __data["fundingForAiConsent"] }
      public var fundingForAiOption: Bool? { __data["fundingForAiOption"] }
      public var generatedByAiConsent: String? { __data["generatedByAiConsent"] }
      public var generatedByAiDetails: String? { __data["generatedByAiDetails"] }
      public var involvesAi: Bool { __data["involvesAi"] }
      public var involvesFunding: Bool { __data["involvesFunding"] }
      public var involvesGeneration: Bool { __data["involvesGeneration"] }
      public var involvesOther: Bool { __data["involvesOther"] }
      public var otherAiDetails: String? { __data["otherAiDetails"] }
    }

    /// Faqs
    ///
    /// Parent Type: `ProjectFaqConnection`
    public struct Faqs: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ProjectFaqConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("nodes", [Node?]?.self),
      ] }

      /// A list of nodes.
      public var nodes: [Node?]? { __data["nodes"] }

      /// Faqs.Node
      ///
      /// Parent Type: `ProjectFaq`
      public struct Node: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ProjectFaq }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("question", String.self),
          .field("answer", String.self),
          .field("id", GraphAPI.ID.self),
          .field("createdAt", GraphAPI.DateTime?.self),
        ] }

        /// Faq question
        public var question: String { __data["question"] }
        /// Faq answer
        public var answer: String { __data["answer"] }
        public var id: GraphAPI.ID { __data["id"] }
        /// When faq was posted
        public var createdAt: GraphAPI.DateTime? { __data["createdAt"] }
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
        .field("id", GraphAPI.ID.self),
        .field("videoSources", VideoSources?.self),
      ] }

      public var id: GraphAPI.ID { __data["id"] }
      /// A video's sources (hls, high, base)
      public var videoSources: VideoSources? { __data["videoSources"] }

      /// Video.VideoSources
      ///
      /// Parent Type: `VideoSources`
      public struct VideoSources: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.VideoSources }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("high", High?.self),
          .field("hls", Hls?.self),
        ] }

        public var high: High? { __data["high"] }
        public var hls: Hls? { __data["hls"] }

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
        }
      }
    }
  }

}