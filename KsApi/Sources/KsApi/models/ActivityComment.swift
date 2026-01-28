import Foundation

/**
 FIXME: Previously `DeprecatedComment`, simply renamed because this model is reliant on `/v1/projects/\(project.id)/activities`
 There is no graph support for this endpoint at time of writing.
 Our existing `Comment` model relies on Graph to be created.
 When we have graph support for these endpoints we should do a direct replacement of `ActivityComment` and `ActivityCommentAuthor` with `Comment` and `Comment.Author`
  - `GET /v1/projects/\(project.id)/activities`
 Use cases:
  - `ProjectActivitiesViewController`
  - `KSRAnalytics`
  - `CommentDialogViewController`
 */
public struct ActivityComment {
  public let author: ActivityCommentAuthor
  public let body: String
  public let createdAt: TimeInterval
  public let deletedAt: TimeInterval?
  public let id: Int
}

extension ActivityComment: Decodable {
  enum CodingKeys: String, CodingKey {
    case author
    case body
    case createdAt = "created_at"
    case deletedAt = "deleted_at"
    case id
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.author = try values.decode(ActivityCommentAuthor.self, forKey: .author)
    self.body = try values.decode(String.self, forKey: .body)
    self.createdAt = try values.decode(TimeInterval.self, forKey: .createdAt)
    self.id = try values.decode(Int.self, forKey: .id)

    // Decode a time interval so that non-positive values are coalesced to `nil`. We do this because the API
    // sends back `0` when the comment hasn't been deleted, and we'd rather handle that value as `nil`.
    let value = try values.decodeIfPresent(TimeInterval.self, forKey: .deletedAt) ?? 0
    self.deletedAt = value > 0 ? value : nil
  }
}

extension ActivityComment: Equatable {}

public func == (lhs: ActivityComment, rhs: ActivityComment) -> Bool {
  return lhs.id == rhs.id
}
