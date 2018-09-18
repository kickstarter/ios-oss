import Argo
import Curry
import Runes
import Prelude

public struct Reward {
  public let backersCount: Int?
  public let description: String
  public let endsAt: TimeInterval?
  public let estimatedDeliveryOn: TimeInterval?
  public let id: Int
  public let limit: Int?
  public let minimum: Double
  public let remaining: Int?
  public let rewardsItems: [RewardsItem]
  public let shipping: Shipping
  public let startsAt: TimeInterval?
  public let title: String?

  /// Returns `true` is this is the "fake" "No reward" reward.
  public var isNoReward: Bool {
    return self.id == Reward.noReward.id
  }

  public struct Shipping {
    public let enabled: Bool
    public let preference: Preference?
    public let summary: String?

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
    let tmp1 = curry(Reward.init)
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
