// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchProjectByIdQuery: GraphQLQuery {
  public static let operationName: String = "FetchProjectById"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchProjectById($projectId: Int!, $withStoredCards: Boolean!) { me { __typename chosenCurrency } project(pid: $projectId) { __typename ...ProjectFragment backing { __typename id } flagging { __typename id kind } } }"#,
      fragments: [CategoryFragment.self, CountryFragment.self, LastWaveFragment.self, LocationFragment.self, MoneyFragment.self, PledgeManagerFragment.self, ProjectFragment.self, UserFragment.self, UserStoredCardsFragment.self]
    ))

  public var projectId: Int
  public var withStoredCards: Bool

  public init(
    projectId: Int,
    withStoredCards: Bool
  ) {
    self.projectId = projectId
    self.withStoredCards = withStoredCards
  }

  public var __variables: Variables? { [
    "projectId": projectId,
    "withStoredCards": withStoredCards
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("me", Me?.self),
      .field("project", Project?.self, arguments: ["pid": .variable("projectId")]),
    ] }

    /// You.
    public var me: Me? { __data["me"] }
    /// Fetches a project given its slug or pid.
    public var project: Project? { __data["project"] }

    public init(
      me: Me? = nil,
      project: Project? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "me": me._fieldData,
          "project": project._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(FetchProjectByIdQuery.Data.self)
        ]
      ))
    }

    /// Me
    ///
    /// Parent Type: `User`
    public struct Me: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("chosenCurrency", String?.self),
      ] }

      /// The user's chosen currency
      public var chosenCurrency: String? { __data["chosenCurrency"] }

      public init(
        chosenCurrency: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.User.typename,
            "chosenCurrency": chosenCurrency,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FetchProjectByIdQuery.Data.Me.self)
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
        .field("backing", Backing?.self),
        .field("flagging", Flagging?.self),
        .fragment(ProjectFragment.self),
      ] }

      /// The current user's backing of this project.  Does not include inactive backings.
      public var backing: Backing? { __data["backing"] }
      /// A report by the current user for the project.
      public var flagging: Flagging? { __data["flagging"] }
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

      public init(
        backing: Backing? = nil,
        flagging: Flagging? = nil,
        availableCardTypes: [GraphQLEnum<GraphAPI.CreditCardTypes>],
        backersCount: Int,
        category: Category? = nil,
        canComment: Bool,
        commentsCount: Int,
        country: Country,
        creator: Creator? = nil,
        currency: GraphQLEnum<GraphAPI.CurrencyCode>,
        deadlineAt: GraphAPI.DateTime? = nil,
        description: String,
        environmentalCommitments: [EnvironmentalCommitment?]? = nil,
        aiDisclosure: AiDisclosure? = nil,
        faqs: Faqs? = nil,
        finalCollectionDate: GraphAPI.ISO8601DateTime? = nil,
        fxRate: Double,
        goal: Goal? = nil,
        image: Image? = nil,
        isPledgeOverTimeAllowed: Bool,
        isProjectWeLove: Bool,
        isProjectOfTheDay: Bool? = nil,
        isWatched: Bool,
        isLaunched: Bool,
        isInPostCampaignPledgingPhase: Bool,
        lastWave: LastWave? = nil,
        launchedAt: GraphAPI.DateTime? = nil,
        location: Location? = nil,
        maxPledge: Int,
        minPledge: Int,
        name: String,
        pid: Int,
        pledgeManager: PledgeManager? = nil,
        pledgeOverTimeCollectionPlanChargeExplanation: String? = nil,
        pledgeOverTimeCollectionPlanChargedAsNPayments: String? = nil,
        pledgeOverTimeCollectionPlanShortPitch: String? = nil,
        pledgeOverTimeMinimumExplanation: String? = nil,
        pledged: Pledged,
        postCampaignPledgingEnabled: Bool,
        posts: Posts? = nil,
        prelaunchActivated: Bool,
        projectNotice: String? = nil,
        redemptionPageUrl: String,
        risks: String,
        sendMetaCapiEvents: Bool,
        slug: String,
        state: GraphQLEnum<GraphAPI.ProjectState>,
        stateChangedAt: GraphAPI.DateTime,
        story: GraphAPI.HTML,
        tags: [Tag?],
        url: String,
        usdExchangeRate: Double? = nil,
        video: Video? = nil,
        watchesCount: Int? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Project.typename,
            "backing": backing._fieldData,
            "flagging": flagging._fieldData,
            "availableCardTypes": availableCardTypes,
            "backersCount": backersCount,
            "category": category._fieldData,
            "canComment": canComment,
            "commentsCount": commentsCount,
            "country": country._fieldData,
            "creator": creator._fieldData,
            "currency": currency,
            "deadlineAt": deadlineAt,
            "description": description,
            "environmentalCommitments": environmentalCommitments._fieldData,
            "aiDisclosure": aiDisclosure._fieldData,
            "faqs": faqs._fieldData,
            "finalCollectionDate": finalCollectionDate,
            "fxRate": fxRate,
            "goal": goal._fieldData,
            "image": image._fieldData,
            "isPledgeOverTimeAllowed": isPledgeOverTimeAllowed,
            "isProjectWeLove": isProjectWeLove,
            "isProjectOfTheDay": isProjectOfTheDay,
            "isWatched": isWatched,
            "isLaunched": isLaunched,
            "isInPostCampaignPledgingPhase": isInPostCampaignPledgingPhase,
            "lastWave": lastWave._fieldData,
            "launchedAt": launchedAt,
            "location": location._fieldData,
            "maxPledge": maxPledge,
            "minPledge": minPledge,
            "name": name,
            "pid": pid,
            "pledgeManager": pledgeManager._fieldData,
            "pledgeOverTimeCollectionPlanChargeExplanation": pledgeOverTimeCollectionPlanChargeExplanation,
            "pledgeOverTimeCollectionPlanChargedAsNPayments": pledgeOverTimeCollectionPlanChargedAsNPayments,
            "pledgeOverTimeCollectionPlanShortPitch": pledgeOverTimeCollectionPlanShortPitch,
            "pledgeOverTimeMinimumExplanation": pledgeOverTimeMinimumExplanation,
            "pledged": pledged._fieldData,
            "postCampaignPledgingEnabled": postCampaignPledgingEnabled,
            "posts": posts._fieldData,
            "prelaunchActivated": prelaunchActivated,
            "projectNotice": projectNotice,
            "redemptionPageUrl": redemptionPageUrl,
            "risks": risks,
            "sendMetaCapiEvents": sendMetaCapiEvents,
            "slug": slug,
            "state": state,
            "stateChangedAt": stateChangedAt,
            "story": story,
            "tags": tags._fieldData,
            "url": url,
            "usdExchangeRate": usdExchangeRate,
            "video": video._fieldData,
            "watchesCount": watchesCount,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FetchProjectByIdQuery.Data.Project.self),
            ObjectIdentifier(ProjectFragment.self)
          ]
        ))
      }

      /// Project.Backing
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
              ObjectIdentifier(FetchProjectByIdQuery.Data.Project.Backing.self)
            ]
          ))
        }
      }

      /// Project.Flagging
      ///
      /// Parent Type: `Flagging`
      public struct Flagging: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Flagging }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GraphAPI.ID.self),
          .field("kind", GraphQLEnum<GraphAPI.FlaggingKind>?.self),
        ] }

        public var id: GraphAPI.ID { __data["id"] }
        /// The general reason for the flagging.
        public var kind: GraphQLEnum<GraphAPI.FlaggingKind>? { __data["kind"] }

        public init(
          id: GraphAPI.ID,
          kind: GraphQLEnum<GraphAPI.FlaggingKind>? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Flagging.typename,
              "id": id,
              "kind": kind,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchProjectByIdQuery.Data.Project.Flagging.self)
            ]
          ))
        }
      }

      /// Project.Category
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
              ObjectIdentifier(FetchProjectByIdQuery.Data.Project.Category.self),
              ObjectIdentifier(ProjectFragment.Category.self),
              ObjectIdentifier(CategoryFragment.self)
            ]
          ))
        }

        public typealias ParentCategory = CategoryFragment.ParentCategory
      }

      /// Project.Country
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
              ObjectIdentifier(FetchProjectByIdQuery.Data.Project.Country.self),
              ObjectIdentifier(ProjectFragment.Country.self),
              ObjectIdentifier(CountryFragment.self)
            ]
          ))
        }
      }

      /// Project.Creator
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

        public init(
          backings: Backings? = nil,
          backingsCount: Int,
          chosenCurrency: String? = nil,
          createdProjects: CreatedProjects? = nil,
          email: String? = nil,
          hasPassword: Bool? = nil,
          hasUnreadMessages: Bool? = nil,
          hasUnseenActivity: Bool? = nil,
          id: GraphAPI.ID,
          imageUrl: String,
          isAppleConnected: Bool? = nil,
          isBlocked: Bool? = nil,
          isCreator: Bool? = nil,
          isDeliverable: Bool? = nil,
          isEmailVerified: Bool? = nil,
          isFacebookConnected: Bool? = nil,
          isKsrAdmin: Bool? = nil,
          isFollowing: Bool,
          isSocializing: Bool? = nil,
          location: Location? = nil,
          name: String,
          needsFreshFacebookToken: Bool? = nil,
          newsletterSubscriptions: NewsletterSubscriptions? = nil,
          notifications: [Notification]? = nil,
          optedOutOfRecommendations: Bool? = nil,
          showPublicProfile: Bool? = nil,
          savedProjects: SavedProjects? = nil,
          storedCards: StoredCards? = nil,
          surveyResponses: SurveyResponses? = nil,
          uid: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.User.typename,
              "backings": backings._fieldData,
              "backingsCount": backingsCount,
              "chosenCurrency": chosenCurrency,
              "createdProjects": createdProjects._fieldData,
              "email": email,
              "hasPassword": hasPassword,
              "hasUnreadMessages": hasUnreadMessages,
              "hasUnseenActivity": hasUnseenActivity,
              "id": id,
              "imageUrl": imageUrl,
              "isAppleConnected": isAppleConnected,
              "isBlocked": isBlocked,
              "isCreator": isCreator,
              "isDeliverable": isDeliverable,
              "isEmailVerified": isEmailVerified,
              "isFacebookConnected": isFacebookConnected,
              "isKsrAdmin": isKsrAdmin,
              "isFollowing": isFollowing,
              "isSocializing": isSocializing,
              "location": location._fieldData,
              "name": name,
              "needsFreshFacebookToken": needsFreshFacebookToken,
              "newsletterSubscriptions": newsletterSubscriptions._fieldData,
              "notifications": notifications._fieldData,
              "optedOutOfRecommendations": optedOutOfRecommendations,
              "showPublicProfile": showPublicProfile,
              "savedProjects": savedProjects._fieldData,
              "storedCards": storedCards._fieldData,
              "surveyResponses": surveyResponses._fieldData,
              "uid": uid,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchProjectByIdQuery.Data.Project.Creator.self),
              ObjectIdentifier(ProjectFragment.Creator.self),
              ObjectIdentifier(UserFragment.self)
            ]
          ))
        }

        public typealias Backings = UserFragment.Backings

        public typealias CreatedProjects = UserFragment.CreatedProjects

        /// Project.Creator.Location
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
                ObjectIdentifier(FetchProjectByIdQuery.Data.Project.Creator.Location.self),
                ObjectIdentifier(UserFragment.Location.self),
                ObjectIdentifier(LocationFragment.self)
              ]
            ))
          }
        }

        public typealias NewsletterSubscriptions = UserFragment.NewsletterSubscriptions

        public typealias Notification = UserFragment.Notification

        public typealias SavedProjects = UserFragment.SavedProjects

        /// Project.Creator.StoredCards
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

          public init(
            nodes: [Node?]? = nil,
            totalCount: Int
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.UserCreditCardTypeConnection.typename,
                "nodes": nodes._fieldData,
                "totalCount": totalCount,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchProjectByIdQuery.Data.Project.Creator.StoredCards.self),
                ObjectIdentifier(UserFragment.StoredCards.self),
                ObjectIdentifier(UserStoredCardsFragment.self)
              ]
            ))
          }

          public typealias Node = UserStoredCardsFragment.Node
        }

        public typealias SurveyResponses = UserFragment.SurveyResponses
      }

      public typealias EnvironmentalCommitment = ProjectFragment.EnvironmentalCommitment

      public typealias AiDisclosure = ProjectFragment.AiDisclosure

      public typealias Faqs = ProjectFragment.Faqs

      /// Project.Goal
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
              ObjectIdentifier(FetchProjectByIdQuery.Data.Project.Goal.self),
              ObjectIdentifier(ProjectFragment.Goal.self),
              ObjectIdentifier(MoneyFragment.self)
            ]
          ))
        }
      }

      public typealias Image = ProjectFragment.Image

      /// Project.LastWave
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
              ObjectIdentifier(FetchProjectByIdQuery.Data.Project.LastWave.self),
              ObjectIdentifier(ProjectFragment.LastWave.self),
              ObjectIdentifier(LastWaveFragment.self)
            ]
          ))
        }
      }

      /// Project.Location
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
              ObjectIdentifier(FetchProjectByIdQuery.Data.Project.Location.self),
              ObjectIdentifier(ProjectFragment.Location.self),
              ObjectIdentifier(LocationFragment.self)
            ]
          ))
        }
      }

      /// Project.PledgeManager
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
              ObjectIdentifier(FetchProjectByIdQuery.Data.Project.PledgeManager.self),
              ObjectIdentifier(ProjectFragment.PledgeManager.self),
              ObjectIdentifier(PledgeManagerFragment.self)
            ]
          ))
        }
      }

      /// Project.Pledged
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
              ObjectIdentifier(FetchProjectByIdQuery.Data.Project.Pledged.self),
              ObjectIdentifier(ProjectFragment.Pledged.self),
              ObjectIdentifier(MoneyFragment.self)
            ]
          ))
        }
      }

      public typealias Posts = ProjectFragment.Posts

      public typealias Tag = ProjectFragment.Tag

      public typealias Video = ProjectFragment.Video
    }
  }
}
