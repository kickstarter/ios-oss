// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Comment: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Comment
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Comment>>

  public struct MockFields {
    @Field<User>("author") public var author
    @Field<[GraphQLEnum<GraphAPI.CommentBadge>?]>("authorBadges") public var authorBadges
    @Field<String>("body") public var body
    @Field<GraphAPI.DateTime>("createdAt") public var createdAt
    @Field<Bool>("deleted") public var deleted
    @Field<Bool>("hasFlaggings") public var hasFlaggings
    @Field<GraphAPI.ID>("id") public var id
    @Field<String>("parentId") public var parentId
    @Field<Bool>("removedPerGuidelines") public var removedPerGuidelines
    @Field<CommentConnection>("replies") public var replies
    @Field<Bool>("sustained") public var sustained
  }
}

public extension Mock where O == Comment {
  convenience init(
    author: Mock<User>? = nil,
    authorBadges: [GraphQLEnum<GraphAPI.CommentBadge>]? = nil,
    body: String? = nil,
    createdAt: GraphAPI.DateTime? = nil,
    deleted: Bool? = nil,
    hasFlaggings: Bool? = nil,
    id: GraphAPI.ID? = nil,
    parentId: String? = nil,
    removedPerGuidelines: Bool? = nil,
    replies: Mock<CommentConnection>? = nil,
    sustained: Bool? = nil
  ) {
    self.init()
    _setEntity(author, for: \.author)
    _setScalarList(authorBadges, for: \.authorBadges)
    _setScalar(body, for: \.body)
    _setScalar(createdAt, for: \.createdAt)
    _setScalar(deleted, for: \.deleted)
    _setScalar(hasFlaggings, for: \.hasFlaggings)
    _setScalar(id, for: \.id)
    _setScalar(parentId, for: \.parentId)
    _setScalar(removedPerGuidelines, for: \.removedPerGuidelines)
    _setEntity(replies, for: \.replies)
    _setScalar(sustained, for: \.sustained)
  }
}
