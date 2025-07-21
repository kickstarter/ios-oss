// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CommentBaseFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CommentBaseFragment on Comment { __typename author { __typename id imageUrl(width: 200) isBlocked isCreator name } authorBadges body createdAt deleted id parentId hasFlaggings removedPerGuidelines sustained }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Comment }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("author", Author?.self),
    .field("authorBadges", [GraphQLEnum<GraphAPI.CommentBadge>?]?.self),
    .field("body", String.self),
    .field("createdAt", GraphAPI.DateTime?.self),
    .field("deleted", Bool.self),
    .field("id", GraphAPI.ID.self),
    .field("parentId", String?.self),
    .field("hasFlaggings", Bool.self),
    .field("removedPerGuidelines", Bool.self),
    .field("sustained", Bool.self),
  ] }

  /// The author of the comment
  public var author: Author? { __data["author"] }
  /// The badges for the comment author
  public var authorBadges: [GraphQLEnum<GraphAPI.CommentBadge>?]? { __data["authorBadges"] }
  /// The body of the comment
  public var body: String { __data["body"] }
  /// When was this comment posted
  public var createdAt: GraphAPI.DateTime? { __data["createdAt"] }
  /// Whether the comment is deleted
  public var deleted: Bool { __data["deleted"] }
  public var id: GraphAPI.ID { __data["id"] }
  /// The ID of the parent comment
  public var parentId: String? { __data["parentId"] }
  /// Whether a comment has any flaggings
  public var hasFlaggings: Bool { __data["hasFlaggings"] }
  /// Whether the comment author has been removed by kickstarter
  public var removedPerGuidelines: Bool { __data["removedPerGuidelines"] }
  /// Whether this comment has been reviewed and sustained by an admin
  public var sustained: Bool { __data["sustained"] }

  public init(
    author: Author? = nil,
    authorBadges: [GraphQLEnum<GraphAPI.CommentBadge>?]? = nil,
    body: String,
    createdAt: GraphAPI.DateTime? = nil,
    deleted: Bool,
    id: GraphAPI.ID,
    parentId: String? = nil,
    hasFlaggings: Bool,
    removedPerGuidelines: Bool,
    sustained: Bool
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Comment.typename,
        "author": author._fieldData,
        "authorBadges": authorBadges,
        "body": body,
        "createdAt": createdAt,
        "deleted": deleted,
        "id": id,
        "parentId": parentId,
        "hasFlaggings": hasFlaggings,
        "removedPerGuidelines": removedPerGuidelines,
        "sustained": sustained,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CommentBaseFragment.self)
      ]
    ))
  }

  /// Author
  ///
  /// Parent Type: `User`
  public struct Author: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", GraphAPI.ID.self),
      .field("imageUrl", String.self, arguments: ["width": 200]),
      .field("isBlocked", Bool?.self),
      .field("isCreator", Bool?.self),
      .field("name", String.self),
    ] }

    public var id: GraphAPI.ID { __data["id"] }
    /// The user's avatar.
    public var imageUrl: String { __data["imageUrl"] }
    /// Is user blocked by current user
    public var isBlocked: Bool? { __data["isBlocked"] }
    /// Whether a user is a creator of any project
    public var isCreator: Bool? { __data["isCreator"] }
    /// The user's provided name.
    public var name: String { __data["name"] }

    public init(
      id: GraphAPI.ID,
      imageUrl: String,
      isBlocked: Bool? = nil,
      isCreator: Bool? = nil,
      name: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.User.typename,
          "id": id,
          "imageUrl": imageUrl,
          "isBlocked": isBlocked,
          "isCreator": isCreator,
          "name": name,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CommentBaseFragment.Author.self)
        ]
      ))
    }
  }
}
