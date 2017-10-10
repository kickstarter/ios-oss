import Argo
import Curry
import Runes

public struct RewardsItem {
  public private(set) var id: Int
  public private(set) var item: Item
  public private(set) var quantity: Int
  public private(set) var rewardId: Int
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
