// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PPOProjectFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment PPOProjectFragment on Project { __typename creator { __typename email id name } image { __typename id url(width: 1024) } name pid slug }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("creator", Creator?.self),
    .field("image", Image?.self),
    .field("name", String.self),
    .field("pid", Int.self),
    .field("slug", String.self),
  ] }

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

  public init(
    creator: Creator? = nil,
    image: Image? = nil,
    name: String,
    pid: Int,
    slug: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Project.typename,
        "creator": creator._fieldData,
        "image": image._fieldData,
        "name": name,
        "pid": pid,
        "slug": slug,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PPOProjectFragment.self)
      ]
    ))
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
      .field("email", String?.self),
      .field("id", GraphAPI.ID.self),
      .field("name", String.self),
    ] }

    /// A user's email address.
    public var email: String? { __data["email"] }
    public var id: GraphAPI.ID { __data["id"] }
    /// The user's provided name.
    public var name: String { __data["name"] }

    public init(
      email: String? = nil,
      id: GraphAPI.ID,
      name: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.User.typename,
          "email": email,
          "id": id,
          "name": name,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PPOProjectFragment.Creator.self)
        ]
      ))
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

    public init(
      id: GraphAPI.ID,
      url: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Photo.typename,
          "id": id,
          "url": url,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PPOProjectFragment.Image.self)
        ]
      ))
    }
  }
}
