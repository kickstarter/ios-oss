// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchCommentRepliesQuery: GraphQLQuery {
  public static let operationName: String = "FetchCommentReplies"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchCommentReplies($commentId: ID!, $cursor: String, $limit: Int!) { comment: node(id: $commentId) { __typename ...CommentWithRepliesFragment } }"#,
      fragments: [CommentBaseFragment.self, CommentFragment.self, CommentWithRepliesFragment.self]
    ))

  public var commentId: ID
  public var cursor: GraphQLNullable<String>
  public var limit: Int

  public init(
    commentId: ID,
    cursor: GraphQLNullable<String>,
    limit: Int
  ) {
    self.commentId = commentId
    self.cursor = cursor
    self.limit = limit
  }

  public var __variables: Variables? { [
    "commentId": commentId,
    "cursor": cursor,
    "limit": limit
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("node", alias: "comment", Comment?.self, arguments: ["id": .variable("commentId")]),
    ] }

    /// Fetches an object given its ID.
    public var comment: Comment? { __data["comment"] }

    public init(
      comment: Comment? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "comment": comment._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(FetchCommentRepliesQuery.Data.self)
        ]
      ))
    }

    /// Comment
    ///
    /// Parent Type: `Node`
    public struct Comment: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Interfaces.Node }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .inlineFragment(AsComment.self),
      ] }

      public var asComment: AsComment? { _asInlineFragment() }

      public init(
        __typename: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FetchCommentRepliesQuery.Data.Comment.self)
          ]
        ))
      }

      /// Comment.AsComment
      ///
      /// Parent Type: `Comment`
      public struct AsComment: GraphAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = FetchCommentRepliesQuery.Data.Comment
        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Comment }
        public static var __selections: [ApolloAPI.Selection] { [
          .fragment(CommentWithRepliesFragment.self),
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

          public var commentWithRepliesFragment: CommentWithRepliesFragment { _toFragment() }
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
              ObjectIdentifier(FetchCommentRepliesQuery.Data.Comment.self),
              ObjectIdentifier(FetchCommentRepliesQuery.Data.Comment.AsComment.self),
              ObjectIdentifier(CommentWithRepliesFragment.self),
              ObjectIdentifier(CommentBaseFragment.self)
            ]
          ))
        }

        public typealias Replies = CommentWithRepliesFragment.Replies

        public typealias Author = CommentBaseFragment.Author
      }
    }
  }
}
