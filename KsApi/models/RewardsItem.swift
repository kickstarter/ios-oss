import Curry
import Runes

public struct RewardsItem {
  public let id: Int
  public let item: Item
  public let quantity: Int
  public let rewardId: Int
}

extension RewardsItem: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case item = "item"
    case quantity = "quantity"
    case rewardId = "reward_id"
  }
}

extension RewardsItem: Decodable {
  public static func decode(_ json: JSON) -> Decoded<RewardsItem> {
    return curry(RewardsItem.init)
      <^> json <| "id"
      <*> json <| "item"
      <*> json <| "quantity"
      <*> json <| "reward_id"
  }
}
