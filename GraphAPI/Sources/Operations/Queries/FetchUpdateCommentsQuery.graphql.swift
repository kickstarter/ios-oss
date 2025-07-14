// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchUpdateCommentsQuery: GraphQLQuery {
  public static let operationName: String = "FetchUpdateComments"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchUpdateComments($postId: ID!, $cursor: String, $limit: Int) { post(id: $postId) { __typename ... on FreeformPost { comments(after: $cursor, first: $limit) { __typename edges { __typename node { __typename ...CommentFragment } } pageInfo { __typename endCursor hasNextPage } totalCount } id } } }"#,
      fragments: [CommentBaseFragment.self, CommentFragment.self]
    ))

  public var postId: ID
  public var cursor: GraphQLNullable<String>
  public var limit: GraphQLNullable<Int>

  public init(
    postId: ID,
    cursor: GraphQLNullable<String>,
    limit: GraphQLNullable<Int>
  ) {
    self.postId = postId
    self.cursor = cursor
    self.limit = limit
  }

  public var __variables: Variables? { [
    "postId": postId,
    "cursor": cursor,
    "limit": limit
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("post", Post?.self, arguments: ["id": .variable("postId")]),
    ] }

    /// Fetches a post given its ID.
    public var post: Post? { __data["post"] }

    /// Post
    ///
    /// Parent Type: `Postable`
    public struct Post: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Interfaces.Postable }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .inlineFragment(AsFreeformPost.self),
      ] }

      public var asFreeformPost: AsFreeformPost? { _asInlineFragment() }

      /// Post.AsFreeformPost
      ///
      /// Parent Type: `FreeformPost`
      public struct AsFreeformPost: GraphAPI.InlineFragment {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = FetchUpdateCommentsQuery.Data.Post
        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.FreeformPost }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("comments", Comments?.self, arguments: [
            "after": .variable("cursor"),
            "first": .variable("limit")
          ]),
          .field("id", GraphAPI.ID.self),
        ] }

        /// List of comments on the commentable
        public var comments: Comments? { __data["comments"] }
        public var id: GraphAPI.ID { __data["id"] }

        /// Post.AsFreeformPost.Comments
        ///
        /// Parent Type: `CommentConnection`
        public struct Comments: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CommentConnection }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("edges", [Edge?]?.self),
            .field("pageInfo", PageInfo.self),
            .field("totalCount", Int.self),
          ] }

          /// A list of edges.
          public var edges: [Edge?]? { __data["edges"] }
          /// Information to aid in pagination.
          public var pageInfo: PageInfo { __data["pageInfo"] }
          public var totalCount: Int { __data["totalCount"] }

          /// Post.AsFreeformPost.Comments.Edge
          ///
          /// Parent Type: `CommentEdge`
          public struct Edge: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CommentEdge }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("node", Node?.self),
            ] }

            /// The item at the end of the edge.
            public var node: Node? { __data["node"] }

            /// Post.AsFreeformPost.Comments.Edge.Node
            ///
            /// Parent Type: `Comment`
            public struct Node: GraphAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Comment }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(CommentFragment.self),
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

                public var commentFragment: CommentFragment { _toFragment() }
                public var commentBaseFragment: CommentBaseFragment { _toFragment() }
              }

              public typealias Replies = CommentFragment.Replies

              public typealias Author = CommentBaseFragment.Author
            }
          }

          /// Post.AsFreeformPost.Comments.PageInfo
          ///
          /// Parent Type: `PageInfo`
          public struct PageInfo: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PageInfo }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("endCursor", String?.self),
              .field("hasNextPage", Bool.self),
            ] }

            /// When paginating forwards, the cursor to continue.
            public var endCursor: String? { __data["endCursor"] }
            /// When paginating forwards, are there more items?
            public var hasNextPage: Bool { __data["hasNextPage"] }
          }
        }
      }
    }
  }
}
