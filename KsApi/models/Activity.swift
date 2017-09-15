import Foundation
import Argo
import Curry
import Runes

public struct Activity {
  public private(set) var category: Activity.Category
  public private(set) var comment: Comment?
  public private(set) var createdAt: TimeInterval
  public private(set) var id: Int
  public private(set) var memberData: MemberData
  public private(set) var project: Project?
  public private(set) var update: Update?
  public private(set) var user: User?

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
    public private(set) var amount: Int?
    public private(set) var backing: Backing?
    public private(set) var oldAmount: Int?
    public private(set) var oldRewardId: Int?
    public private(set) var newAmount: Int?
    public private(set) var newRewardId: Int?
    public private(set) var rewardId: Int?
  }
}

extension Activity: Equatable {
}
public func == (lhs: Activity, rhs: Activity) -> Bool {
  return lhs.id == rhs.id
}

extension Activity: Argo.Decodable {
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

extension Activity.Category: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Activity.Category> {
    switch json {
    case let .string(category):
      return .success(Activity.Category(rawValue: category) ?? .unknown)
    default:
      return .failure(.typeMismatch(expected: "String", actual: json.description))
    }
  }
}

extension Activity.MemberData: Argo.Decodable {
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
