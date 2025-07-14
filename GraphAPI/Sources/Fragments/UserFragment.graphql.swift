// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct UserFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment UserFragment on User { __typename backings { __typename nodes { __typename errorReason } } backingsCount chosenCurrency createdProjects { __typename totalCount } email hasPassword hasUnreadMessages hasUnseenActivity id imageUrl: imageUrl(blur: false, width: 1024) isAppleConnected isBlocked isCreator isDeliverable isEmailVerified isFacebookConnected isKsrAdmin isFollowing isSocializing location { __typename ...LocationFragment } name needsFreshFacebookToken newsletterSubscriptions { __typename artsCultureNewsletter filmNewsletter musicNewsletter inventNewsletter gamesNewsletter publishingNewsletter promoNewsletter weeklyNewsletter happeningNewsletter alumniNewsletter } notifications { __typename email mobile topic } optedOutOfRecommendations showPublicProfile savedProjects { __typename totalCount } storedCards @include(if: $withStoredCards) { __typename ...UserStoredCardsFragment } surveyResponses(answered: false) { __typename totalCount } uid }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("backings", Backings?.self),
    .field("backingsCount", Int.self),
    .field("chosenCurrency", String?.self),
    .field("createdProjects", CreatedProjects?.self),
    .field("email", String?.self),
    .field("hasPassword", Bool?.self),
    .field("hasUnreadMessages", Bool?.self),
    .field("hasUnseenActivity", Bool?.self),
    .field("id", GraphAPI.ID.self),
    .field("imageUrl", alias: "imageUrl", String.self, arguments: [
      "blur": false,
      "width": 1024
    ]),
    .field("isAppleConnected", Bool?.self),
    .field("isBlocked", Bool?.self),
    .field("isCreator", Bool?.self),
    .field("isDeliverable", Bool?.self),
    .field("isEmailVerified", Bool?.self),
    .field("isFacebookConnected", Bool?.self),
    .field("isKsrAdmin", Bool?.self),
    .field("isFollowing", Bool.self),
    .field("isSocializing", Bool?.self),
    .field("location", Location?.self),
    .field("name", String.self),
    .field("needsFreshFacebookToken", Bool?.self),
    .field("newsletterSubscriptions", NewsletterSubscriptions?.self),
    .field("notifications", [Notification]?.self),
    .field("optedOutOfRecommendations", Bool?.self),
    .field("showPublicProfile", Bool?.self),
    .field("savedProjects", SavedProjects?.self),
    .field("surveyResponses", SurveyResponses?.self, arguments: ["answered": false]),
    .field("uid", String.self),
    .include(if: "withStoredCards", .field("storedCards", StoredCards?.self)),
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
        ObjectIdentifier(UserFragment.self)
      ]
    ))
  }

  /// Backings
  ///
  /// Parent Type: `UserBackingsConnection`
  public struct Backings: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserBackingsConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("nodes", [Node?]?.self),
    ] }

    /// A list of nodes.
    public var nodes: [Node?]? { __data["nodes"] }

    public init(
      nodes: [Node?]? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.UserBackingsConnection.typename,
          "nodes": nodes._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(UserFragment.Backings.self)
        ]
      ))
    }

    /// Backings.Node
    ///
    /// Parent Type: `Backing`
    public struct Node: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Backing }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("errorReason", String?.self),
      ] }

      /// The reason for an errored backing
      public var errorReason: String? { __data["errorReason"] }

      public init(
        errorReason: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Backing.typename,
            "errorReason": errorReason,
          ],
          fulfilledFragments: [
            ObjectIdentifier(UserFragment.Backings.Node.self)
          ]
        ))
      }
    }
  }

  /// CreatedProjects
  ///
  /// Parent Type: `UserCreatedProjectsConnection`
  public struct CreatedProjects: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserCreatedProjectsConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("totalCount", Int.self),
    ] }

    public var totalCount: Int { __data["totalCount"] }

    public init(
      totalCount: Int
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.UserCreatedProjectsConnection.typename,
          "totalCount": totalCount,
        ],
        fulfilledFragments: [
          ObjectIdentifier(UserFragment.CreatedProjects.self)
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
          ObjectIdentifier(UserFragment.Location.self),
          ObjectIdentifier(LocationFragment.self)
        ]
      ))
    }
  }

  /// NewsletterSubscriptions
  ///
  /// Parent Type: `NewsletterSubscriptions`
  public struct NewsletterSubscriptions: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.NewsletterSubscriptions }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("artsCultureNewsletter", Bool.self),
      .field("filmNewsletter", Bool.self),
      .field("musicNewsletter", Bool.self),
      .field("inventNewsletter", Bool.self),
      .field("gamesNewsletter", Bool.self),
      .field("publishingNewsletter", Bool.self),
      .field("promoNewsletter", Bool.self),
      .field("weeklyNewsletter", Bool.self),
      .field("happeningNewsletter", Bool.self),
      .field("alumniNewsletter", Bool.self),
    ] }

    /// The subscription to the ArtsCultureNewsletter newsletter
    public var artsCultureNewsletter: Bool { __data["artsCultureNewsletter"] }
    /// The subscription to the FilmNewsletter newsletter
    public var filmNewsletter: Bool { __data["filmNewsletter"] }
    /// The subscription to the MusicNewsletter newsletter
    public var musicNewsletter: Bool { __data["musicNewsletter"] }
    /// The subscription to the InventNewsletter newsletter
    public var inventNewsletter: Bool { __data["inventNewsletter"] }
    /// The subscription to the GamesNewsletter newsletter
    public var gamesNewsletter: Bool { __data["gamesNewsletter"] }
    /// The subscription to the PublishingNewsletter newsletter
    public var publishingNewsletter: Bool { __data["publishingNewsletter"] }
    /// The subscription to the PromoNewsletter newsletter
    public var promoNewsletter: Bool { __data["promoNewsletter"] }
    /// The subscription to the WeeklyNewsletter newsletter
    public var weeklyNewsletter: Bool { __data["weeklyNewsletter"] }
    /// The subscription to the HappeningNewsletter newsletter
    public var happeningNewsletter: Bool { __data["happeningNewsletter"] }
    /// The subscription to the AlumniNewsletter newsletter
    public var alumniNewsletter: Bool { __data["alumniNewsletter"] }

    public init(
      artsCultureNewsletter: Bool,
      filmNewsletter: Bool,
      musicNewsletter: Bool,
      inventNewsletter: Bool,
      gamesNewsletter: Bool,
      publishingNewsletter: Bool,
      promoNewsletter: Bool,
      weeklyNewsletter: Bool,
      happeningNewsletter: Bool,
      alumniNewsletter: Bool
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.NewsletterSubscriptions.typename,
          "artsCultureNewsletter": artsCultureNewsletter,
          "filmNewsletter": filmNewsletter,
          "musicNewsletter": musicNewsletter,
          "inventNewsletter": inventNewsletter,
          "gamesNewsletter": gamesNewsletter,
          "publishingNewsletter": publishingNewsletter,
          "promoNewsletter": promoNewsletter,
          "weeklyNewsletter": weeklyNewsletter,
          "happeningNewsletter": happeningNewsletter,
          "alumniNewsletter": alumniNewsletter,
        ],
        fulfilledFragments: [
          ObjectIdentifier(UserFragment.NewsletterSubscriptions.self)
        ]
      ))
    }
  }

  /// Notification
  ///
  /// Parent Type: `Notification`
  public struct Notification: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Notification }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("email", Bool.self),
      .field("mobile", Bool.self),
      .field("topic", GraphQLEnum<GraphAPI.UserNotificationTopic>.self),
    ] }

    /// Are email notifications enabled for this topic
    public var email: Bool { __data["email"] }
    /// Are mobile notifications enabled for this topic
    public var mobile: Bool { __data["mobile"] }
    /// The topic of the notification
    public var topic: GraphQLEnum<GraphAPI.UserNotificationTopic> { __data["topic"] }

    public init(
      email: Bool,
      mobile: Bool,
      topic: GraphQLEnum<GraphAPI.UserNotificationTopic>
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Notification.typename,
          "email": email,
          "mobile": mobile,
          "topic": topic,
        ],
        fulfilledFragments: [
          ObjectIdentifier(UserFragment.Notification.self)
        ]
      ))
    }
  }

  /// SavedProjects
  ///
  /// Parent Type: `UserSavedProjectsConnection`
  public struct SavedProjects: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserSavedProjectsConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("totalCount", Int.self),
    ] }

    public var totalCount: Int { __data["totalCount"] }

    public init(
      totalCount: Int
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.UserSavedProjectsConnection.typename,
          "totalCount": totalCount,
        ],
        fulfilledFragments: [
          ObjectIdentifier(UserFragment.SavedProjects.self)
        ]
      ))
    }
  }

  /// StoredCards
  ///
  /// Parent Type: `UserCreditCardTypeConnection`
  public struct StoredCards: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserCreditCardTypeConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(UserStoredCardsFragment.self),
    ] }

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
          ObjectIdentifier(UserFragment.StoredCards.self),
          ObjectIdentifier(UserStoredCardsFragment.self)
        ]
      ))
    }

    public typealias Node = UserStoredCardsFragment.Node
  }

  /// SurveyResponses
  ///
  /// Parent Type: `SurveyResponsesConnection`
  public struct SurveyResponses: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.SurveyResponsesConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("totalCount", Int.self),
    ] }

    public var totalCount: Int { __data["totalCount"] }

    public init(
      totalCount: Int
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.SurveyResponsesConnection.typename,
          "totalCount": totalCount,
        ],
        fulfilledFragments: [
          ObjectIdentifier(UserFragment.SurveyResponses.self)
        ]
      ))
    }
  }
}
