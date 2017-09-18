import Argo
import Curry
import Runes

public struct RewardsItem {
  public let id: Int
  public let item: Item
  public let quantity: Int
  public let rewardId: Int
}

extension RewardsItem: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<RewardsItem> {
    return curry(RewardsItem.init)
      <^> json <| "id"
      <*> json <| "item"
      <*> json <| "quantity"
      <*> json <| "reward_id"
  }
}
