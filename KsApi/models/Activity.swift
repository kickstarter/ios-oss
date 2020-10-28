import Curry
import Foundation
import Runes

public struct Activity {
  public let category: Activity.Category
  public let comment: Comment?
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

extension Activity: Swift.Decodable {
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
    self.comment = try values.decodeIfPresent(Comment.self, forKey: .comment)
    self.createdAt = try values.decode(TimeInterval.self, forKey: .createdAt)
    self.id = try values.decode(Int.self, forKey: .id)
    self.memberData = try Activity.MemberData(from: decoder)
    self.project = try values.decodeIfPresent(Project.self, forKey: .project)
    self.update = try values.decodeIfPresent(Update.self, forKey: .update)
    self.user = try values.decodeIfPresent(User.self, forKey: .user)
  }
}

/*
 extension Activity: Decodable {
 public static func decode(_ json: JSON) -> Decoded<Activity> {
   let tmp = curry(Activity.init)
     <^> json <| "category"
     <*> json <|? "comment"
     <*> json <| "created_at"
     <*> json <| "id"
   return tmp
     <*> Activity.MemberData.decode(json)
     <*> ((json <|? "project" >>- tryDecodable) as Decoded<Project?>)
     <*> json <|? "update"
     <*> ((json <|? "user" >>- tryDecodable) as Decoded<User?>)
 }
 }
 */
extension Activity.Category: Swift.Decodable {
  public init(from decoder: Decoder) throws {
    self = try Activity.Category(rawValue: decoder.singleValueContainer().decode(String.self)) ?? .unknown
  }
}

extension Activity.Category: Decodable {
  public static func decode(_ json: JSON) -> Decoded<Activity.Category> {
    switch json {
    case let .string(category):
      return .success(Activity.Category(rawValue: category) ?? .unknown)
    default:
      return .failure(.typeMismatch(expected: "String", actual: json.description))
    }
  }
}

extension Activity.MemberData: Swift.Decodable {
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

/*
 extension Activity.MemberData: Decodable {
 public static func decode(_ json: JSON) -> Decoded<Activity.MemberData> {
   let tmp = curry(Activity.MemberData.init)
     <^> json <|? "amount"
     <*> json <|? "backing"
     <*> json <|? "old_amount"
     <*> json <|? "old_reward_id"
   return tmp
     <*> json <|? "new_amount"
     <*> json <|? "new_reward_id"
     <*> json <|? "reward_id"
 }
 }
 */
