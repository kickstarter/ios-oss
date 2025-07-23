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

    public init(
      post: Post? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "post": post._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(FetchUpdateCommentsQuery.Data.self)
        ]
      ))
    }

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

      public init(
        __typename: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FetchUpdateCommentsQuery.Data.Post.self)
          ]
        ))
      }

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

        public init(
          comments: Comments? = nil,
          id: GraphAPI.ID
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.FreeformPost.typename,
              "comments": comments._fieldData,
              "id": id,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchUpdateCommentsQuery.Data.Post.self),
              ObjectIdentifier(FetchUpdateCommentsQuery.Data.Post.AsFreeformPost.self)
            ]
          ))
        }

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

          public init(
            edges: [Edge?]? = nil,
            pageInfo: PageInfo,
            totalCount: Int
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.CommentConnection.typename,
                "edges": edges._fieldData,
                "pageInfo": pageInfo._fieldData,
                "totalCount": totalCount,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchUpdateCommentsQuery.Data.Post.AsFreeformPost.Comments.self)
              ]
            ))
          }

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

            public init(
              node: Node? = nil
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.CommentEdge.typename,
                  "node": node._fieldData,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(FetchUpdateCommentsQuery.Data.Post.AsFreeformPost.Comments.Edge.self)
                ]
              ))
            }

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
                    ObjectIdentifier(FetchUpdateCommentsQuery.Data.Post.AsFreeformPost.Comments.Edge.Node.self),
                    ObjectIdentifier(CommentFragment.self),
                    ObjectIdentifier(CommentBaseFragment.self)
                  ]
                ))
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

            public init(
              endCursor: String? = nil,
              hasNextPage: Bool
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.PageInfo.typename,
                  "endCursor": endCursor,
                  "hasNextPage": hasNextPage,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(FetchUpdateCommentsQuery.Data.Post.AsFreeformPost.Comments.PageInfo.self)
                ]
              ))
            }
          }
        }
      }
    }
  }
}
