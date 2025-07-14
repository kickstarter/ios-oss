// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchProjectFriendsBySlugQuery: GraphQLQuery {
  public static let operationName: String = "FetchProjectFriendsBySlug"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchProjectFriendsBySlug($slug: String!, $withStoredCards: Boolean!) { project(slug: $slug) { __typename friends { __typename nodes { __typename ...UserFragment } } } }"#,
      fragments: [LocationFragment.self, UserFragment.self, UserStoredCardsFragment.self]
    ))

  public var slug: String
  public var withStoredCards: Bool

  public init(
    slug: String,
    withStoredCards: Bool
  ) {
    self.slug = slug
    self.withStoredCards = withStoredCards
  }

  public var __variables: Variables? { [
    "slug": slug,
    "withStoredCards": withStoredCards
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("project", Project?.self, arguments: ["slug": .variable("slug")]),
    ] }

    /// Fetches a project given its slug or pid.
    public var project: Project? { __data["project"] }

    /// Project
    ///
    /// Parent Type: `Project`
    public struct Project: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("friends", Friends?.self),
      ] }

      /// A project's friendly backers.
      public var friends: Friends? { __data["friends"] }

      /// Project.Friends
      ///
      /// Parent Type: `ProjectBackerFriendsConnection`
      public struct Friends: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ProjectBackerFriendsConnection }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
        ] }

        /// A list of nodes.
        public var nodes: [Node?]? { __data["nodes"] }

        /// Project.Friends.Node
        ///
        /// Parent Type: `User`
        public struct Node: GraphAPI.SelectionSet {
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

          /// Project.Friends.Node.Location
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

          /// Project.Friends.Node.StoredCards
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
      }
    }
  }
}
