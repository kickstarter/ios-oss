// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// All available comment author badges
public enum CommentBadge: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Indicates the author is a creator
  case creator
  /// Indicates the author is a collaborator
  case collaborator
  /// Indicates the author is a superbacker
  case superbacker
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "creator": self = .creator
      case "collaborator": self = .collaborator
      case "superbacker": self = .superbacker
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .creator: return "creator"
      case .collaborator: return "collaborator"
      case .superbacker: return "superbacker"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: CommentBadge, rhs: CommentBadge) -> Bool {
    switch (lhs, rhs) {
      case (.creator, .creator): return true
      case (.collaborator, .collaborator): return true
      case (.superbacker, .superbacker): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [CommentBadge] {
    return [
      .creator,
      .collaborator,
      .superbacker,
    ]
  }
}

public final class FetchProjectCommentsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query FetchProjectComments($slug: String!, $cursor: String, $limit: Int) {
      project(slug: $slug) {
        __typename
        comments(after: $cursor, first: $limit) {
          __typename
          edges {
            __typename
            node {
              __typename
              ...CommentFragment
            }
          }
          pageInfo {
            __typename
            endCursor
            hasNextPage
          }
          totalCount
        }
        id
        slug
      }
    }
    """

  public let operationName: String = "FetchProjectComments"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + CommentFragment.fragmentDefinition)
    return document
  }

  public var slug: String
  public var cursor: String?
  public var limit: Int?

  public init(slug: String, cursor: String? = nil, limit: Int? = nil) {
    self.slug = slug
    self.cursor = cursor
    self.limit = limit
  }

  public var variables: GraphQLMap? {
    return ["slug": slug, "cursor": cursor, "limit": limit]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("project", arguments: ["slug": GraphQLVariable("slug")], type: .object(Project.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(project: Project? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "project": project.flatMap { (value: Project) -> ResultMap in value.resultMap }])
    }

    /// Fetches a project given its slug or pid.
    public var project: Project? {
      get {
        return (resultMap["project"] as? ResultMap).flatMap { Project(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "project")
      }
    }

    public struct Project: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Project"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("comments", arguments: ["after": GraphQLVariable("cursor"), "first": GraphQLVariable("limit")], type: .object(Comment.selections)),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("slug", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(comments: Comment? = nil, id: GraphQLID, slug: String) {
        self.init(unsafeResultMap: ["__typename": "Project", "comments": comments.flatMap { (value: Comment) -> ResultMap in value.resultMap }, "id": id, "slug": slug])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// List of comments on the commentable
      public var comments: Comment? {
        get {
          return (resultMap["comments"] as? ResultMap).flatMap { Comment(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "comments")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// The project's unique URL identifier.
      public var slug: String {
        get {
          return resultMap["slug"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "slug")
        }
      }

      public struct Comment: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["CommentConnection"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("edges", type: .list(.object(Edge.selections))),
            GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
            GraphQLField("totalCount", type: .nonNull(.scalar(Int.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(edges: [Edge?]? = nil, pageInfo: PageInfo, totalCount: Int) {
          self.init(unsafeResultMap: ["__typename": "CommentConnection", "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, "pageInfo": pageInfo.resultMap, "totalCount": totalCount])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// A list of edges.
        public var edges: [Edge?]? {
          get {
            return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
          }
        }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo {
          get {
            return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
          }
        }

        public var totalCount: Int {
          get {
            return resultMap["totalCount"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "totalCount")
          }
        }

        public struct Edge: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["CommentEdge"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("node", type: .object(Node.selections)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(node: Node? = nil) {
            self.init(unsafeResultMap: ["__typename": "CommentEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The item at the end of the edge.
          public var node: Node? {
            get {
              return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "node")
            }
          }

          public struct Node: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Comment"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLFragmentSpread(CommentFragment.self),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var commentFragment: CommentFragment {
                get {
                  return CommentFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }

        public struct PageInfo: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PageInfo"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("endCursor", type: .scalar(String.self)),
              GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(endCursor: String? = nil, hasNextPage: Bool) {
            self.init(unsafeResultMap: ["__typename": "PageInfo", "endCursor": endCursor, "hasNextPage": hasNextPage])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? {
            get {
              return resultMap["endCursor"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "endCursor")
            }
          }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool {
            get {
              return resultMap["hasNextPage"]! as! Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "hasNextPage")
            }
          }
        }
      }
    }
  }
}

public final class FetchUpdateCommentsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query FetchUpdateComments($postId: ID!, $cursor: String, $limit: Int) {
      post(id: $postId) {
        __typename
        ... on FreeformPost {
          comments(after: $cursor, first: $limit) {
            __typename
            edges {
              __typename
              node {
                __typename
                ...CommentFragment
              }
            }
            pageInfo {
              __typename
              endCursor
              hasNextPage
            }
            totalCount
          }
          id
        }
      }
    }
    """

  public let operationName: String = "FetchUpdateComments"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + CommentFragment.fragmentDefinition)
    return document
  }

  public var postId: GraphQLID
  public var cursor: String?
  public var limit: Int?

  public init(postId: GraphQLID, cursor: String? = nil, limit: Int? = nil) {
    self.postId = postId
    self.cursor = cursor
    self.limit = limit
  }

  public var variables: GraphQLMap? {
    return ["postId": postId, "cursor": cursor, "limit": limit]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("post", arguments: ["id": GraphQLVariable("postId")], type: .object(Post.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(post: Post? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "post": post.flatMap { (value: Post) -> ResultMap in value.resultMap }])
    }

    /// Fetches a post given its ID.
    public var post: Post? {
      get {
        return (resultMap["post"] as? ResultMap).flatMap { Post(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "post")
      }
    }

    public struct Post: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CreatorInterview", "FreeformPost"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLTypeCase(
            variants: ["FreeformPost": AsFreeformPost.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeCreatorInterview() -> Post {
        return Post(unsafeResultMap: ["__typename": "CreatorInterview"])
      }

      public static func makeFreeformPost(comments: AsFreeformPost.Comment? = nil, id: GraphQLID) -> Post {
        return Post(unsafeResultMap: ["__typename": "FreeformPost", "comments": comments.flatMap { (value: AsFreeformPost.Comment) -> ResultMap in value.resultMap }, "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asFreeformPost: AsFreeformPost? {
        get {
          if !AsFreeformPost.possibleTypes.contains(__typename) { return nil }
          return AsFreeformPost(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsFreeformPost: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["FreeformPost"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("comments", arguments: ["after": GraphQLVariable("cursor"), "first": GraphQLVariable("limit")], type: .object(Comment.selections)),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(comments: Comment? = nil, id: GraphQLID) {
          self.init(unsafeResultMap: ["__typename": "FreeformPost", "comments": comments.flatMap { (value: Comment) -> ResultMap in value.resultMap }, "id": id])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// List of comments on the commentable
        public var comments: Comment? {
          get {
            return (resultMap["comments"] as? ResultMap).flatMap { Comment(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "comments")
          }
        }

        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public struct Comment: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["CommentConnection"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("edges", type: .list(.object(Edge.selections))),
              GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
              GraphQLField("totalCount", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(edges: [Edge?]? = nil, pageInfo: PageInfo, totalCount: Int) {
            self.init(unsafeResultMap: ["__typename": "CommentConnection", "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, "pageInfo": pageInfo.resultMap, "totalCount": totalCount])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A list of edges.
          public var edges: [Edge?]? {
            get {
              return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
            }
          }

          /// Information to aid in pagination.
          public var pageInfo: PageInfo {
            get {
              return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
            }
          }

          public var totalCount: Int {
            get {
              return resultMap["totalCount"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "totalCount")
            }
          }

          public struct Edge: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["CommentEdge"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("node", type: .object(Node.selections)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(node: Node? = nil) {
              self.init(unsafeResultMap: ["__typename": "CommentEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// The item at the end of the edge.
            public var node: Node? {
              get {
                return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "node")
              }
            }

            public struct Node: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Comment"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLFragmentSpread(CommentFragment.self),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var commentFragment: CommentFragment {
                  get {
                    return CommentFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }
            }
          }

          public struct PageInfo: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["PageInfo"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("endCursor", type: .scalar(String.self)),
                GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(endCursor: String? = nil, hasNextPage: Bool) {
              self.init(unsafeResultMap: ["__typename": "PageInfo", "endCursor": endCursor, "hasNextPage": hasNextPage])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// When paginating forwards, the cursor to continue.
            public var endCursor: String? {
              get {
                return resultMap["endCursor"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "endCursor")
              }
            }

            /// When paginating forwards, are there more items?
            public var hasNextPage: Bool {
              get {
                return resultMap["hasNextPage"]! as! Bool
              }
              set {
                resultMap.updateValue(newValue, forKey: "hasNextPage")
              }
            }
          }
        }
      }
    }
  }
}

public struct CommentFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CommentFragment on Comment {
      __typename
      author {
        __typename
        id
        imageUrl(width: 200)
        isCreator
        name
      }
      authorBadges
      body
      createdAt
      deleted
      id
      parentId
      replies {
        __typename
        totalCount
      }
    }
    """

  public static let possibleTypes: [String] = ["Comment"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("author", type: .object(Author.selections)),
      GraphQLField("authorBadges", type: .list(.scalar(CommentBadge.self))),
      GraphQLField("body", type: .nonNull(.scalar(String.self))),
      GraphQLField("createdAt", type: .scalar(String.self)),
      GraphQLField("deleted", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
      GraphQLField("parentId", type: .scalar(String.self)),
      GraphQLField("replies", type: .object(Reply.selections)),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(author: Author? = nil, authorBadges: [CommentBadge?]? = nil, body: String, createdAt: String? = nil, deleted: Bool, id: GraphQLID, parentId: String? = nil, replies: Reply? = nil) {
    self.init(unsafeResultMap: ["__typename": "Comment", "author": author.flatMap { (value: Author) -> ResultMap in value.resultMap }, "authorBadges": authorBadges, "body": body, "createdAt": createdAt, "deleted": deleted, "id": id, "parentId": parentId, "replies": replies.flatMap { (value: Reply) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The author of the comment
  public var author: Author? {
    get {
      return (resultMap["author"] as? ResultMap).flatMap { Author(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "author")
    }
  }

  /// The badges for the comment author
  public var authorBadges: [CommentBadge?]? {
    get {
      return resultMap["authorBadges"] as? [CommentBadge?]
    }
    set {
      resultMap.updateValue(newValue, forKey: "authorBadges")
    }
  }

  /// The body of the comment
  public var body: String {
    get {
      return resultMap["body"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "body")
    }
  }

  /// When was this comment posted
  public var createdAt: String? {
    get {
      return resultMap["createdAt"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  /// Whether the comment is deleted
  public var deleted: Bool {
    get {
      return resultMap["deleted"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "deleted")
    }
  }

  public var id: GraphQLID {
    get {
      return resultMap["id"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  /// The ID of the parent comment
  public var parentId: String? {
    get {
      return resultMap["parentId"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "parentId")
    }
  }

  /// The replies on a comment
  public var replies: Reply? {
    get {
      return (resultMap["replies"] as? ResultMap).flatMap { Reply(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "replies")
    }
  }

  public struct Author: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["User"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("imageUrl", arguments: ["width": 200], type: .nonNull(.scalar(String.self))),
        GraphQLField("isCreator", type: .scalar(Bool.self)),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: GraphQLID, imageUrl: String, isCreator: Bool? = nil, name: String) {
      self.init(unsafeResultMap: ["__typename": "User", "id": id, "imageUrl": imageUrl, "isCreator": isCreator, "name": name])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var id: GraphQLID {
      get {
        return resultMap["id"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    /// The user's avatar.
    public var imageUrl: String {
      get {
        return resultMap["imageUrl"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "imageUrl")
      }
    }

    /// Whether a user is a creator
    public var isCreator: Bool? {
      get {
        return resultMap["isCreator"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "isCreator")
      }
    }

    /// The user's provided name.
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }
  }

  public struct Reply: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["CommentConnection"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("totalCount", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(totalCount: Int) {
      self.init(unsafeResultMap: ["__typename": "CommentConnection", "totalCount": totalCount])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var totalCount: Int {
      get {
        return resultMap["totalCount"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "totalCount")
      }
    }
  }
}
