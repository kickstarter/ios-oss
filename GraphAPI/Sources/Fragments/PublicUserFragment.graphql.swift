// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PublicUserFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PublicUserFragment on User { __typename id imageUrl: imageUrl(blur: false, width: 1024) isBlocked isFollowing location { __typename ...LocationFragment } name showPublicProfile uid backingsCount createdProjects { __typename totalCount } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", GraphAPI.ID.self),
    .field("imageUrl", alias: "imageUrl", String.self, arguments: [
      "blur": false,
      "width": 1024
    ]),
    .field("isBlocked", Bool?.self),
    .field("isFollowing", Bool.self),
    .field("location", Location?.self),
    .field("name", String.self),
    .field("showPublicProfile", Bool?.self),
    .field("uid", String.self),
    .field("backingsCount", Int.self),
    .field("createdProjects", CreatedProjects?.self),
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
        ObjectIdentifier(PublicUserFragment.self)
      ]
    ))
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
          ObjectIdentifier(PublicUserFragment.Location.self),
          ObjectIdentifier(LocationFragment.self)
        ]
      ))
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
          ObjectIdentifier(PublicUserFragment.CreatedProjects.self)
        ]
      ))
    }
  }
}
