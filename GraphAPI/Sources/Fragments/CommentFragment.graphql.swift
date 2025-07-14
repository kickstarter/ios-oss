// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CommentFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CommentFragment on Comment { __typename ...CommentBaseFragment replies { __typename totalCount } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Comment }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("replies", Replies?.self),
    .fragment(CommentBaseFragment.self),
  ] }

  /// The replies on a comment
  public var replies: Replies? { __data["replies"] }
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

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public var commentBaseFragment: CommentBaseFragment { _toFragment() }
  }

  public init(
    replies: Replies? = nil,
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
        "replies": replies._fieldData,
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
        ObjectIdentifier(CommentFragment.self),
        ObjectIdentifier(CommentBaseFragment.self)
      ]
    ))
  }

  /// Replies
  ///
  /// Parent Type: `CommentConnection`
  public struct Replies: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CommentConnection }
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
          "__typename": GraphAPI.Objects.CommentConnection.typename,
          "totalCount": totalCount,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CommentFragment.Replies.self)
        ]
      ))
    }
  }

  public typealias Author = CommentBaseFragment.Author
}
