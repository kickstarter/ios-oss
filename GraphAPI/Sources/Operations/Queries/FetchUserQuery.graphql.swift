// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchUserQuery: GraphQLQuery {
  public static let operationName: String = "FetchUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchUser($withStoredCards: Boolean!) { me { __typename ...UserFragment } }"#,
      fragments: [LocationFragment.self, UserFragment.self, UserStoredCardsFragment.self]
    ))

  public var withStoredCards: Bool

  public init(withStoredCards: Bool) {
    self.withStoredCards = withStoredCards
  }

  public var __variables: Variables? { ["withStoredCards": withStoredCards] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("me", Me?.self),
    ] }

    /// You.
    public var me: Me? { __data["me"] }

    public init(
      me: Me? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "me": me._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(FetchUserQuery.Data.self)
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
            ObjectIdentifier(FetchUserQuery.Data.Me.self),
            ObjectIdentifier(UserFragment.self)
          ]
        ))
      }

      public typealias Backings = UserFragment.Backings

      public typealias CreatedProjects = UserFragment.CreatedProjects

      /// Me.Location
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
              ObjectIdentifier(FetchUserQuery.Data.Me.Location.self),
              ObjectIdentifier(UserFragment.Location.self),
              ObjectIdentifier(LocationFragment.self)
            ]
          ))
        }
      }

      public typealias NewsletterSubscriptions = UserFragment.NewsletterSubscriptions

      public typealias Notification = UserFragment.Notification

      public typealias SavedProjects = UserFragment.SavedProjects

      /// Me.StoredCards
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
              ObjectIdentifier(FetchUserQuery.Data.Me.StoredCards.self),
              ObjectIdentifier(UserFragment.StoredCards.self),
              ObjectIdentifier(UserStoredCardsFragment.self)
            ]
          ))
        }

        public typealias Node = UserStoredCardsFragment.Node
      }

      public typealias SurveyResponses = UserFragment.SurveyResponses
    }
  }
}
