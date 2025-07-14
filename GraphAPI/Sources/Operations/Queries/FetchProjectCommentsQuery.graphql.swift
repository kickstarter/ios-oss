// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchProjectCommentsQuery: GraphQLQuery {
  public static let operationName: String = "FetchProjectComments"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchProjectComments($slug: String!, $cursor: String, $limit: Int) { project(slug: $slug) { __typename comments(after: $cursor, first: $limit) { __typename edges { __typename node { __typename ...CommentFragment } } pageInfo { __typename endCursor hasNextPage } totalCount } id slug } }"#,
      fragments: [CommentBaseFragment.self, CommentFragment.self]
    ))

  public var slug: String
  public var cursor: GraphQLNullable<String>
  public var limit: GraphQLNullable<Int>

  public init(
    slug: String,
    cursor: GraphQLNullable<String>,
    limit: GraphQLNullable<Int>
  ) {
    self.slug = slug
    self.cursor = cursor
    self.limit = limit
  }

  public var __variables: Variables? { [
    "slug": slug,
    "cursor": cursor,
    "limit": limit
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
        .field("comments", Comments?.self, arguments: [
          "after": .variable("cursor"),
          "first": .variable("limit")
        ]),
        .field("id", GraphAPI.ID.self),
        .field("slug", String.self),
      ] }

      /// List of comments on the commentable
      public var comments: Comments? { __data["comments"] }
      public var id: GraphAPI.ID { __data["id"] }
      /// The project's unique URL identifier.
      public var slug: String { __data["slug"] }

      /// Project.Comments
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

        /// Project.Comments.Edge
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

          /// Project.Comments.Edge.Node
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

        /// Project.Comments.PageInfo
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
