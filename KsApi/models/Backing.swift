import Argo
import Curry
import Runes

public struct Backing {
  public private(set) var amount: Int
  public private(set) var backer: User?
  public private(set) var backerId: Int
  public private(set) var id: Int
  public private(set) var locationId: Int?
  public private(set) var pledgedAt: TimeInterval
  public private(set) var projectCountry: String
  public private(set) var projectId: Int
  public private(set) var reward: Reward?
  public private(set) var rewardId: Int?
  public private(set) var sequence: Int
  public private(set) var shippingAmount: Int?
  public private(set) var status: Status

  public enum Status: String {
    case canceled
    case collected
    case dropped
    case errored
    case pledged
    case preauth
  }
}

extension Backing: Equatable {
}
public func == (lhs: Backing, rhs: Backing) -> Bool {
  return lhs.id == rhs.id
}

extension Backing: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Backing> {
    let create = curry(Backing.init)
    let tmp1 = create
      <^> json <| "amount"
      <*> json <|? "backer"
      <*> json <| "backer_id"
      <*> json <| "id"
    let tmp2 = tmp1
      <*> json <|? "location_id"
      <*> json <| "pledged_at"
      <*> json <| "project_country"
      <*> json <| "project_id"
    return tmp2
      <*> json <|? "reward"
      <*> json <|? "reward_id"
      <*> json <| "sequence"
      <*> json <|? "shipping_amount"
      <*> json <| "status"
  }
}

extension Backing.Status: Argo.Decodable {
}
