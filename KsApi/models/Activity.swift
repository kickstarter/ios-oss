import Foundation
import Argo
import Curry
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
    case backing          = "backing"
    case backingAmount    = "backing-amount"
    case backingCanceled  = "backing-canceled"
    case backingDropped   = "backing-dropped"
    case backingReward    = "backing-reward"
    case cancellation     = "cancellation"
    case commentPost      = "comment-post"
    case commentProject   = "comment-project"
    case failure          = "failure"
    case follow           = "follow"
    case funding          = "funding"
    case launch           = "launch"
    case success          = "success"
    case suspension       = "suspension"
    case update           = "update"
    case watch            = "watch"
    case unknown          = "unknown"
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

extension Activity: Equatable {
}
public func == (lhs: Activity, rhs: Activity) -> Bool {
  return lhs.id == rhs.id
}

extension Activity: Decodable {
  public static func decode(_ json: JSON) -> Decoded<Activity> {
    let create = curry(Activity.init)
    let tmp = create
      <^> json <|  "category"
      <*> json <|? "comment"
      <*> json <|  "created_at"
      <*> json <|  "id"
    return tmp
      <*> Activity.MemberData.decode(json)
      <*> json <|? "project"
      <*> json <|? "update"
      <*> json <|? "user"
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

extension Activity.MemberData: Decodable {
  public static func decode(_ json: JSON) -> Decoded<Activity.MemberData> {
    let create = curry(Activity.MemberData.init)
    let tmp = create
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
