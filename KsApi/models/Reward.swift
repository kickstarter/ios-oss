import Argo
import Curry
import Runes
import Prelude

public struct Reward {
  public private(set) var backersCount: Int?
  public private(set) var description: String
  public private(set) var endsAt: TimeInterval?
  public private(set) var estimatedDeliveryOn: TimeInterval?
  public private(set) var id: Int
  public private(set) var limit: Int?
  public private(set) var minimum: Int
  public private(set) var remaining: Int?
  public private(set) var rewardsItems: [RewardsItem]
  public private(set) var shipping: Shipping
  public private(set) var startsAt: TimeInterval?
  public private(set) var title: String?

  /// Returns `true` is this is the "fake" "No reward" reward.
  public var isNoReward: Bool {
    return self.id == Reward.noReward.id
  }

  public struct Shipping {
    public private(set) var enabled: Bool
    public private(set) var preference: Preference?
    public private(set) var summary: String?

    public enum Preference: String {
      case none
      case restricted
      case unrestricted
    }
  }
}

extension Reward: Equatable {}
public func == (lhs: Reward, rhs: Reward) -> Bool {
  return lhs.id == rhs.id
}

private let minimumAndIdComparator = Reward.lens.minimum.comparator <> Reward.lens.id.comparator

extension Reward: Comparable {}
public func < (lhs: Reward, rhs: Reward) -> Bool {
  return minimumAndIdComparator.isOrdered(lhs, rhs)
}

extension Reward: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Reward> {
    let create = curry(Reward.init)
    let tmp1 = create
      <^> json <|? "backers_count"
      <*> (json <| "description" <|> json <| "reward")
      <*> json <|? "ends_at"
      <*> json <|? "estimated_delivery_on"
    let tmp2 = tmp1
      <*> json <| "id"
      <*> json <|? "limit"
      <*> json <| "minimum"
      <*> json <|? "remaining"
    return tmp2
      <*> ((json <|| "rewards_items") <|> .success([]))
      <*> Reward.Shipping.decode(json)
      <*> json <|? "starts_at"
      <*> json <|? "title"
  }
}

extension Reward.Shipping: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Reward.Shipping> {
    return curry(Reward.Shipping.init)
      <^> (json <| "shipping_enabled" <|> .success(false))
      <*> json <|? "shipping_preference"
      <*> json <|? "shipping_summary"
  }
}

extension Reward.Shipping.Preference: Argo.Decodable {}
