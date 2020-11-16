

public struct RewardsItem {
  public let id: Int
  public let item: Item
  public let quantity: Int
  public let rewardId: Int
}

extension RewardsItem: Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case item
    case quantity
    case rewardId = "reward_id"
  }
}
