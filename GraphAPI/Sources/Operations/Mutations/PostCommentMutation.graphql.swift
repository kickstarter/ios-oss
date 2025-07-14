// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PostCommentMutation: GraphQLMutation {
  public static let operationName: String = "PostComment"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation PostComment($input: PostCommentInput!) { createComment(input: $input) { __typename comment { __typename ...CommentFragment } } }"#,
      fragments: [CommentBaseFragment.self, CommentFragment.self]
    ))

  public var input: PostCommentInput

  public init(input: PostCommentInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createComment", CreateComment?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Post a comment
    public var createComment: CreateComment? { __data["createComment"] }

    /// CreateComment
    ///
    /// Parent Type: `PostCommentPayload`
    public struct CreateComment: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PostCommentPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("comment", Comment?.self),
      ] }

      public var comment: Comment? { __data["comment"] }

      /// CreateComment.Comment
      ///
      /// Parent Type: `Comment`
      public struct Comment: GraphAPI.SelectionSet {
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
  }
}
