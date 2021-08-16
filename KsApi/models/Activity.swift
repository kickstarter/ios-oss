
import Foundation

public struct Activity {
  public let category: Activity.Category
  public let comment: ActivityComment?
  public let createdAt: TimeInterval
  public let id: Int
  public let memberData: MemberData
  public let project: Project?
  public let update: Update?
  public let user: User?

  public enum Category: String {
    case backing
    case backingAmount = "backing-amount"
    case backingCanceled = "backing-canceled"
    case backingDropped = "backing-dropped"
    case backingReward = "backing-reward"
    case cancellation
    case commentPost = "comment-post"
    case commentProject = "comment-project"
    case failure
    case follow
    case funding
    case launch
    case success
    case suspension
    case update
    case watch
    case unknown
  }

  public struct MemberData {
    public let amount: Int?
    public let backing: Backing?
    public let oldAmount: Int?
    public let oldRewardId: Int?
    public let newAmount: Int?
    public let newRewardId: Int?
    public let rewardId: Int?
  }
}

extension Activity: Equatable {}

public func == (lhs: Activity, rhs: Activity) -> Bool {
  return lhs.id == rhs.id
}

extension Activity: Decodable {
  enum CodingKeys: String, CodingKey {
    case category
    case comment
    case createdAt = "created_at"
    case id
    case project
    case update
    case user
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.category = try values.decode(Activity.Category.self, forKey: .category)
    self.comment = try values.decodeIfPresent(ActivityComment.self, forKey: .comment)
    self.createdAt = try values.decode(TimeInterval.self, forKey: .createdAt)
    self.id = try values.decode(Int.self, forKey: .id)
    self.memberData = try Activity.MemberData(from: decoder)
    self.project = try values.decodeIfPresent(Project.self, forKey: .project)
    self.update = try values.decodeIfPresent(Update.self, forKey: .update)
    self.user = try values.decodeIfPresent(User.self, forKey: .user)
  }
}

extension Activity.Category: Decodable {
  public init(from decoder: Decoder) throws {
    self = try Activity.Category(rawValue: decoder.singleValueContainer().decode(String.self)) ?? .unknown
  }
}

extension Activity.MemberData: Decodable {
  enum CodingKeys: String, CodingKey {
    case amount
    case backing
    case oldAmount = "old_amount"
    case oldRewardId = "old_reward_id"
    case newAmount = "new_amount"
    case newRewardId = "new_reward_id"
    case rewardId = "reward_id"
  }
}
